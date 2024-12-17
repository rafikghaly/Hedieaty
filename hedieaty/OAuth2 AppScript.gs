// This Script is for FCM to use their new OAuth2 Protocol
var CLIENT_EMAIL = 'service account email'; // Replace HERE
var PRIVATE_KEY = `-----BEGIN PRIVATE KEY-----\n-----END PRIVATE KEY-----\n`; // Replace HERE

function doPost(e) {
  try {
    var data = JSON.parse(e.postData.contents);
    var token = data.token;
    var title = data.title;
    var body = data.body;

    Logger.log('Token: ' + token);
    Logger.log('Title: ' + title);
    Logger.log('Body: ' + body);

    var accessToken = getOAuthToken();

    if (accessToken) {
      Logger.log('Sending Notification...');
      var message = {
        "message": {
          "token": token,
          "notification": {
            "title": title,
            "body": body,
          },
        }
      };

      var options = {
        'method': 'post',
        'contentType': 'application/json',
        'headers': {
          'Authorization': 'Bearer ' + accessToken,
        },
        'payload': JSON.stringify(message)
      };

      var response = UrlFetchApp.fetch('https://fcm.googleapis.com/v1/projects/PROJECT_ID/messages:send', options); // Replace HERE
      Logger.log('Response: ' + response.getContentText());
      return ContentService.createTextOutput(JSON.stringify({'status': 'success', 'message': 'Notification sent successfully.'}));
    } else {
      Logger.log('Failed to get access token');
      return ContentService.createTextOutput(JSON.stringify({'status': 'error', 'message': 'Failed to get access token'}));
    }
  } catch (error) {
    Logger.log('Error in doPost: ' + error.message);
    return ContentService.createTextOutput(JSON.stringify({'status': 'error', 'message': 'Error in doPost: ' + error.message}));
  }
}

function getOAuthToken() {
  var service = OAuth2.createService('FCM')
    .setTokenUrl('https://oauth2.googleapis.com/token')
    .setPrivateKey(PRIVATE_KEY)
    .setIssuer(CLIENT_EMAIL)
    .setScope('https://www.googleapis.com/auth/firebase.messaging')
    .setSubject(CLIENT_EMAIL)
    .setPropertyStore(PropertiesService.getScriptProperties());

  if (!service.hasAccess()) {
    Logger.log('Authorization error: ' + service.getLastError());
    return null;
  }

  var accessToken = service.getAccessToken();
  Logger.log('Access Token: ' + accessToken);
  return accessToken;
}
