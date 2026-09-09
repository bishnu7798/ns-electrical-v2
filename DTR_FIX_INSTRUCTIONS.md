# DTR Search Fix Instructions

## Problem Summary
The DTR search functionality was not working because the Google Apps Script was looking for DTR codes in the first column of the Google Sheet, but the actual DTR codes are in column M (13th column).

## Solution
A fixed Google Apps Script has been created that correctly looks for DTR codes in column M.

## Steps to Fix the DTR Search

### 1. Deploy the Fixed Google Apps Script

1. Go to [Google Apps Script](https://script.google.com/)
2. Click "New Project"
3. Delete the default `Code.gs` file
4. Create a new file and name it `Server.gs`
5. Copy the contents of `fixed_server.gs` file from this project and paste it into the new `Server.gs` file
6. Replace `'YOUR_SPREADSHEET_ID'` with your actual Google Sheet ID:
   ```
   const SPREADSHEET_ID = '1bU4aToTaxpgRaY9au-arLXB7ZwjwBI9v8NKchMkpKxo';
   ```
7. Save the project (Ctrl+S)

### 2. Deploy as Web App

1. Click "Deploy" → "New deployment"
2. Click the gear icon and select "Web app"
3. Configure the deployment:
   - Description: NS Electrical DTR API
   - Execute as: Me
   - Who has access: Anyone (or adjust as needed for security)
4. Click "Deploy"
5. Copy the Web app URL (it will look like `https://script.google.com/macros/s/{SCRIPT_ID}/exec`)

### 3. Update the Flutter App

1. Open `lib/src/core/services/dtr_api_service.dart` in your Flutter project
2. Replace the placeholder URL:
   ```dart
   static const String _apiUrl = 'https://script.google.com/macros/s/YOUR_DEPLOYED_SCRIPT_URL/exec';
   ```
   with your actual Web app URL copied in step 2.5

### 4. Test the Integration

1. Run your Flutter app
2. Navigate to the DTR Search screen
3. Enter a DTR code that exists in your Google Sheet:
   - Try: `6RI42` (from row 3)
   - Try: `6RI03` (from row 4)
   - Try: `6RIOJ` (from row 5)
4. Click the search button
5. The app should now fetch data from your Google Sheet correctly

## How the Fix Works

The original script was looking for DTR codes in column A (index 0):
```javascript
if (data[i][0] == dtrCode) { // Wrong - looking in first column
```

The fixed script looks for DTR codes in column M (index 13):
```javascript
if (data[i][13] == dtrCode) { // Correct - looking in 14th column (M)
```

## Troubleshooting

### Common Issues

1. **"API not configured" error**: 
   - Make sure you've updated the `_apiUrl` in `dtr_api_service.dart` with your actual Web app URL

2. **"DTR code not found anywhere"**: 
   - Verify the DTR code exists in your Google Sheet
   - Check that the DTR code is in column M (13th column)
   - Ensure column headers in your sheet match the script expectations

3. **Permission errors**: 
   - Make sure your Google Apps Script deployment allows access
   - Check that your Google Sheet sharing settings allow access from the script

4. **CORS errors**: 
   - This is usually handled by ContentService in Google Apps Script
   - Make sure you're using `ContentService.createTextOutput()` in your script

### Debugging Tips

1. Check the console logs in your Flutter app for error messages
2. View execution transcripts in Google Apps Script editor
3. Test your Google Apps Script functions directly in the editor
4. Use the Google Apps Script URL Tester to verify your endpoint

## Testing DTR Codes

Here are some DTR codes from your Google Sheet that you can use for testing:
- `6RI42` (Row 3)
- `6RI03` (Row 4)
- `6RIOJ` (Row 5)
- `6RIKN` (Row 6)
- `6RIJV` (Row 7)
- `6RIJS` (Row 8)

These codes should now work correctly with the fixed implementation.