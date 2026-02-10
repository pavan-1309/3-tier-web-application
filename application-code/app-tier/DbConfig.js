const AWS = require('aws-sdk');
const secretsManager = new AWS.SecretsManager({
  region: 'ap-south-1'
});

async function getDatabaseSecrets() {
  try {
    const secretName = "rds-creds";
    const data = await secretsManager.getSecretValue({ SecretId: secretName }).promise();

    if ('SecretString' in data) {
      const secrets = JSON.parse(data.SecretString);
      return {
        DB_HOST: secrets.DB_HOST,
        DB_USER: secrets.DB_USER,
        DB_PWD: secrets.DB_PWD,
        DB_DATABASE: secrets.DB_DATABASE
      };
    }
  } catch (error) {
    console.error('Error retrieving secret:', error);
    throw error;
  }
}

module.exports = getDatabaseSecrets();


