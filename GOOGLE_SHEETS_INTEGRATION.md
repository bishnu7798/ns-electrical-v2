# Google Sheets Integration Guide for NS Electrical App

## Prerequisites

To enable Google Sheets integration for DTR data lookup, you need to:

1. Create a Google Apps Script project
2. Set up the script to connect to your Google Sheet
3. Deploy the script as a web app
4. Update the API URL in the app

## Step-by-Step Instructions

### 1. Create Google Apps Script Project

1. Go to [Google Apps Script](https://script.google.com/)
2. Click "New Project"
3. Delete the default `Code.gs` file
4. Create a new file and name it `Server.gs`
5. Add the following code to `Server.gs`:

```javascript
// Replace 'YOUR_SPREADSHEET_ID' with your actual Google Sheet ID
const SPREADSHEET_ID = 'YOUR_SPREADSHEET_ID';

function doGet(e) {
  const action = e.parameter.action;
  const dtrCode = e.parameter.dtrCode;
  
  if (action === 'getDTR') {
    return getDTRData(dtrCode);
  }
  
  return ContentService.createTextOutput(JSON.stringify({
    error: 'Invalid action'
  })).setMimeType(ContentService.MimeType.JSON);
}

function doPost(e) {
  const action = e.parameter.action;
  
  if (action === 'saveDTR') {
    const data = JSON.parse(e.postData.contents);
    return saveDTRData(data);
  }
  
  return ContentService.createTextOutput(JSON.stringify({
    success: false,
    message: 'Invalid action'
  })).setMimeType(ContentService.MimeType.JSON);
}

function getDTRData(dtrCode) {
  try {
    const sheet = SpreadsheetApp.openById(SPREADSHEET_ID).getActiveSheet();
    const data = sheet.getDataRange().getValues();
    
    // Assuming first row contains headers
    const headers = data[0];
    
    // Find the row with matching DTR code
    for (let i = 1; i < data.length; i++) {
      if (data[i][0] == dtrCode) { // Assuming DTR code is in the first column
        const result = {};
        for (let j = 0; j < headers.length; j++) {
          result[headers[j]] = data[i][j];
        }
        return ContentService.createTextOutput(JSON.stringify(result))
          .setMimeType(ContentService.MimeType.JSON);
      }
    }
    
    // Return empty object if not found
    return ContentService.createTextOutput(JSON.stringify({}))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (error) {
    return ContentService.createTextOutput(JSON.stringify({
      error: error.toString()
    })).setMimeType(ContentService.MimeType.JSON);
  }
}

function saveDTRData(dtrData) {
  try {
    const sheet = SpreadsheetApp.openById(SPREADSHEET_ID).getActiveSheet();
    const data = sheet.getDataRange().getValues();
    
    // Find if DTR code already exists
    let rowIndex = -1;
    for (let i = 1; i < data.length; i++) {
      if (data[i][0] == dtrData.dtrCode) {
        rowIndex = i + 1; // +1 because of 1-indexed rows and header row
        break;
      }
    }
    
    // Prepare data array in the order matching your spreadsheet columns
    const rowData = [
      dtrData.dtrCode,
      dtrData.division,
      dtrData.feeder,
      dtrData.ccc,
      dtrData.block,
      dtrData.gp,
      dtrData.village,
      dtrData.location,
      dtrData.drgNo,
      dtrData.engineerName,
      dtrData.subContractorName,
      dtrData.capacity,
      dtrData.substation,
      dtrData.landMarks,
      dtrData.docDate,
      dtrData.jmcNo,
      dtrData.censusCode
    ];
    
    if (rowIndex > 0) {
      // Update existing row
      sheet.getRange(rowIndex, 1, 1, rowData.length).setValues([rowData]);
    } else {
      // Add new row
      sheet.appendRow(rowData);
    }
    
    return ContentService.createTextOutput(JSON.stringify({
      success: true,
      message: 'DTR data saved successfully'
    })).setMimeType(ContentService.MimeType.JSON);
  } catch (error) {
    return ContentService.createTextOutput(JSON.stringify({
      success: false,
      message: error.toString()
    })).setMimeType(ContentService.MimeType.JSON);
  }
}
```

### 2. Configure Your Google Sheet

1. Create a new Google Sheet
2. Set up your headers in the first row:
   ```
   DTR Code | Division | Feeder | CCC | Block | GP | Village | Location | DRG No | Engineer Name | Sub Contractor Name | Capacity | Substation | Land Marks | D.O.C Date | JMC No | Census Code
   ```
3. Copy the Spreadsheet ID from the URL:
   `https://docs.google.com/spreadsheets/d/[SPREADSHEET_ID]/edit`

### 3. Update the Script

1. Replace `YOUR_SPREADSHEET_ID` in the script with your actual Spreadsheet ID
2. Save the project (Ctrl+S)

### 4. Deploy as Web App

1. Click "Deploy" → "New deployment"
2. Click the gear icon and select "Web app"
3. Configure the deployment:
   - Description: NS Electrical API
   - Execute as: Me
   - Who has access: Anyone (or adjust as needed for security)
4. Click "Deploy"
5. Copy the Web app URL (this is your API URL)

### 5. Update the App Configuration

1. Open `lib/src/core/services/dtr_api_service.dart` in your Flutter project
2. Replace the placeholder URL:
   ```dart
   static const String _apiUrl = 'https://script.google.com/macros/s/YOUR_ACTUAL_SCRIPT_ID/exec';
   ```
   with your actual Web app URL

### 6. Test the Integration

1. Run your Flutter app
2. Navigate to the DTR screen
3. Enter a DTR code that exists in your Google Sheet
4. Click the search button
5. The app should now fetch data from your Google Sheet

## Troubleshooting

### Common Issues

1. **"API not configured" error**: Make sure you've updated the `_apiUrl` in `dtr_api_service.dart`

2. **"DTR code not found anywhere"**: 
   - Verify the DTR code exists in your Google Sheet
   - Check that the DTR code is in the first column
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

## Security Considerations

1. Limit access to your web app to only necessary users
2. Consider adding authentication if sensitive data is involved
3. Regularly review who has access to your deployed web app
4. Use HTTPS endpoints only (Google Apps Script provides this automatically)