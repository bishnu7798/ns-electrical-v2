// Google Apps Script to serve DTR data from Google Sheets

// Deploy this as a web app with GET requests

// Replace 'YOUR_SPREADSHEET_ID' with your actual Google Sheet ID
const SPREADSHEET_ID = '1fBHkMaPCp2x78st5Z-MdHEID6-2Wq-2TJGOfqFv7Kq4';

function doGet(e) {
  try {
    // Get the active spreadsheet
    const sheet = SpreadsheetApp.openById(SPREADSHEET_ID).getActiveSheet();
    
    // Get the action from the request parameters
    const action = e.parameter.action;
    
    if (action === 'getDTR') {
      // Handle the getDTR action (existing functionality)
      const dtrCode = e.parameter.dtrCode;
      
      if (!dtrCode) {
        return ContentService
          .createTextOutput(JSON.stringify({
            success: false,
            errors: ['Missing DTR code parameter']
          }))
          .setMimeType(ContentService.MimeType.JSON);
      }
      
      // Find the row with the matching DTR code in column N (index 13)
      const data = sheet.getDataRange().getValues();
      let rowIndex = -1;
      
      // Search for the DTR code in column N (index 13) - case insensitive
      for (let i = 1; i < data.length; i++) { // Start from 1 to skip header row
        if (data[i][13].toString().toLowerCase().trim() === dtrCode.toString().toLowerCase().trim()) {
          rowIndex = i;
          break;
        }
      }
      
      // If DTR code found, return the data
      if (rowIndex !== -1) {
        // Create a response object with data mapped to field names
        const responseData = {
          // DTR Code is in column N (index 13)
          'dtrCode': data[rowIndex][13],
          // Capacity is in column B (index 1)
          'capacity': data[rowIndex][1],
          // Division is in column C (index 2)
          'division': data[rowIndex][2],
          // Block is in column D (index 3)
          'block': data[rowIndex][3],
          // CCC is in column E (index 4)
          'ccc': data[rowIndex][4],
          // GP is in column F (index 5)
          'gp': data[rowIndex][5],
          // Village is in column G (index 6)
          'village': data[rowIndex][6],
          // Location is in column H (index 7)
          'location': data[rowIndex][7],
          // Land Marks is in column I (index 8)
          'landMarks': data[rowIndex][8],
          // DRG No is in column J (index 9)
          'drgNo': data[rowIndex][9],
          // Census Code is in column K (index 10)
          'censusCode': data[rowIndex][10],
          // DOC Date is in column L (index 11)
          'docDate': data[rowIndex][11],
          // JMC No is in column M (index 12)
          'jmcNo': data[rowIndex][12],
          // Feeder is in column O (index 14)
          'feeder': data[rowIndex][14],
          // Substation is in column P (index 15)
          'substation': data[rowIndex][15]
        };
        
        return ContentService
          .createTextOutput(JSON.stringify({
            success: true,
            data: responseData
          }))
          .setMimeType(ContentService.MimeType.JSON);
      } else {
        // DTR code not found
        return ContentService
          .createTextOutput(JSON.stringify({
            success: false,
            errors: ['DTR code not found']
          }))
          .setMimeType(ContentService.MimeType.JSON);
      }
    } else if (action === 'getAllDTRs') {
      // Handle the getAllDTRs action (new functionality)
      const data = sheet.getDataRange().getValues();
      const dtrList = [];
      
      // Process all rows starting from index 1 to skip header row
      for (let i = 1; i < data.length; i++) {
        // Only include rows that have a DTR code
        if (data[i][13] && data[i][13].toString().trim() !== '') {
          const dtrData = {
            // DTR Code is in column N (index 13)
            'dtrCode': data[i][13],
            // Capacity is in column B (index 1)
            'capacity': data[i][1],
            // Division is in column C (index 2)
            'division': data[i][2],
            // Block is in column D (index 3)
            'block': data[i][3],
            // CCC is in column E (index 4)
            'ccc': data[i][4],
            // GP is in column F (index 5)
            'gp': data[i][5],
            // Village is in column G (index 6)
            'village': data[i][6],
            // Location is in column H (index 7)
            'location': data[i][7],
            // Land Marks is in column I (index 8)
            'landMarks': data[i][8],
            // DRG No is in column J (index 9)
            'drgNo': data[i][9],
            // Census Code is in column K (index 10)
            'censusCode': data[i][10],
            // DOC Date is in column L (index 11)
            'docDate': data[i][11],
            // JMC No is in column M (index 12)
            'jmcNo': data[i][12],
            // Feeder is in column O (index 14)
            'feeder': data[i][14],
            // Substation is in column P (index 15)
            'substation': data[i][15]
          };
          
          dtrList.push(dtrData);
        }
      }
      
      return ContentService
        .createTextOutput(JSON.stringify({
          success: true,
          data: dtrList
        }))
        .setMimeType(ContentService.MimeType.JSON);
    } else {
      // Invalid action
      return ContentService
        .createTextOutput(JSON.stringify({
          success: false,
          errors: ['Invalid action. Supported actions: getDTR, getAllDTRs']
        }))
        .setMimeType(ContentService.MimeType.JSON);
    }
  } catch (error) {
    // Handle any errors
    return ContentService
      .createTextOutput(JSON.stringify({
        success: false,
        errors: ['Server error: ' + error.toString()]
      }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}


// Test function to verify the sheet structure
function testSheetStructure() {
  const sheet = SpreadsheetApp.openById(SPREADSHEET_ID).getActiveSheet();
  const data = sheet.getDataRange().getValues();
  
  Logger.log('Sheet has ' + data.length + ' rows');
  Logger.log('Header row: ' + data[0].join(', '));
  
  // Log first few data rows
  for (let i = 1; i < Math.min(5, data.length); i++) {
    Logger.log('Row ' + i + ': ' + data[i].join(', '));
  }
}