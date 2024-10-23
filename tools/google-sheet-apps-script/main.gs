function jsonResponse(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj)).setMimeType(ContentService.MimeType.JSON);
}

function okResponse() {
  return jsonResponse({ ok: true });
}

function doGet(e) {
  return okResponse();
}

const SECRET = "<secret token>";

function doPost(e) {
  try {
    const json = JSON.parse(e.postData.contents);
    const { token } = json;

    if (!token || token !== SECRET) {
      throw new Error('Invalid token');
    }

    let { pc, mac } = json;

    if (!pc || !mac) {
      return okResponse();
    }

    mac = mac.replaceAll('-', ':');

    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Steam');
    const data = sheet.getDataRange().getValues();
    const columns = data[0];
    const pcColumnIdx = columns.indexOf('PC');
    const macColumnIdx = columns.indexOf('MAC');
    const rowIdx = data.findIndex(row => row[pcColumnIdx] === pc);

    if (rowIdx < 0) {
      return okResponse();
    }

    sheet.getRange(rowIdx + 1, macColumnIdx + 1).setValue(mac);
    SpreadsheetApp.flush();

    return jsonResponse({ ok: true, pc, mac, rowIdx });
  } catch (error) {
    return jsonResponse({ ok: false, error: error?.message || error });
  }
}
