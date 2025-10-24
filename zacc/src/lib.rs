use csv::ReaderBuilder;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct AccelerometerData {
    pub timestamp: f64,
    pub x: f64,
    pub y: f64,
    pub z: f64
}

pub fn read_accelerometer_data(file_path: &str, delimiter: char, start_line: usize) -> Result<Vec<AccelerometerData>, Box<dyn std::error::Error>> {
    let file_content = std::fs::read_to_string(file_path)?;
    // Skip the initial lines of metadata
    let data_str = file_content.lines().skip(start_line).collect::<Vec<_>>().join("\n");

    let mut rdr = ReaderBuilder::new()
        .delimiter(delimiter as u8)
        .comment(Some(b'#'))
        .has_headers(false)
        .from_reader(data_str.as_bytes());
    
    // The `csv` crate's `deserialize` method returns an iterator.
    // We can collect the results directly into a Vec. The `?` operator inside
    // `collect` will propagate any deserialization errors.
    let data = rdr.deserialize().collect::<Result<Vec<_>, _>>()?;

    Ok(data)
}

#[no_mangle]
pub extern "C" fn detect_start(arr_x: *const f64, arr_y: *const f64, arr_z: *const f64, len: usize, threshold: f64) -> usize {
    if arr_x.is_null() || arr_y.is_null() || arr_z.is_null() || len == 0 {
        return 0;
    }
    let slice_x = unsafe { std::slice::from_raw_parts(arr_x, len) };
    let slice_y = unsafe { std::slice::from_raw_parts(arr_y, len) };
    let slice_z = unsafe { std::slice::from_raw_parts(arr_z, len) };
    for i in 0..len {
        let magnitude = (slice_x[i].powi(2) + slice_y[i].powi(2) + slice_z[i].powi(2)).sqrt();
        if magnitude > threshold {
            return i; // Return the index where movement starts
        }
    }
    len // Return len if no start detected
}

pub fn simple_moving_average(arr: Vec<f64>,  window_size: usize) -> Vec<f64> {
    if arr.is_empty() || window_size == 0 || window_size > arr.len() {
        return Vec::new();
    }

    let mut output = Vec::with_capacity(arr.len() - window_size + 1);
    let mut current_sum: f64 = arr[0..window_size].iter().sum();
    output.push(current_sum / (window_size as f64));


    for i in window_size..arr.len() {
        current_sum += arr[i] - arr[i - window_size];
        output.push(current_sum / (window_size as f64));
    }
    output
}

#[no_mangle]
pub fn find_peaks(arr: Vec<f64>, threshold: f64, min_duration: usize) -> Vec<i32> {
    if arr.is_empty() {
        return Vec::new();
    }
    let mut diff: Vec<i32> = Vec::with_capacity(arr.len());
    for i in 1..arr.len()-1 {
        if arr[i] > arr[i - 1] && arr[i] > arr[i + 1]
        && arr[i] > threshold && (i - diff.last().unwrap_or(&0).to_owned() as usize) >= min_duration {
            // Detected a peak
            diff.push(i as i32);
        }
    }
    diff
}

#[no_mangle]
pub extern "C" fn count_peaks(arr: *const f64, len: usize, threshold: f64, min_duration: usize) -> i64 {
    let window_size = 5;
    let arr = unsafe { std::slice::from_raw_parts(arr, len).to_vec() };
    let output = simple_moving_average(arr, window_size);
    let peaks = find_peaks(output, threshold, min_duration);
    print!("Total peak count: {}\n", peaks.len());
    peaks.len() as i64
}


#[no_mangle]
pub extern "C" fn calc_jerk(arr: *const f64, len: usize) -> f64 {
    if arr.is_null() || len == 0 {
        return 0.0;
    }
    let slice = unsafe { std::slice::from_raw_parts(arr, len) };
    let mut sum = 0.0;
    for i in 1..len {
        sum += (slice[i] - slice[i - 1]).abs();
    }
    sum / ((len - 1) as f64)
}


#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_simple_moving_average() {
        let data: Vec<AccelerometerData> = read_accelerometer_data("test_data/bizepsmaschine_20251010225151.csv", '\t', 0).unwrap();

        let arr: Vec<f64> = data.iter().map(|d| d.z).collect();
        let window_size = 5;
        let sma = simple_moving_average(arr.clone(), window_size);
        println!("Simple Moving Average (window size {}): {:?}", window_size, sma);
        assert_eq!(sma.len(), arr.len() - window_size + 1);
    }

    #[test]
    fn test_find_peaks() {
        let data: Vec<AccelerometerData> = read_accelerometer_data("test_data/bizepsmaschine_20251010225151.csv", '\t', 0).unwrap();
        let arr: Vec<f64> = data.iter().map(|d| d.z).collect();
        let peaks = find_peaks(arr.clone(), 10.0, 150);
        println!("Detected peaks at indices: {:?}", peaks);
        assert!(!peaks.is_empty());
    }

    #[test]
    fn count_peaks_test() {
        let data: Vec<AccelerometerData> = read_accelerometer_data("test_data/bizepsmaschine_20251010225151.csv", '\t', 0).unwrap();

        let arr: Vec<f64> = data.iter().map(|d| d.z).collect();
        let peak_count = count_peaks(arr.as_ptr(), arr.len(), 10.0, 150);
        println!("Total peak count: {}", peak_count);

        assert!(peak_count > 0);
    }
}
