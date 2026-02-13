const { SecretsManagerClient, GetSecretValueCommand } = require('@aws-sdk/client-secrets-manager');

const client = new SecretsManagerClient({ region: 'ap-south-1' });

async function getDatabaseSecrets() {
  try {
    const secretName = "rds-secret";
    const command = new GetSecretValueCommand({ SecretId: secretName });
    const data = await client.send(command);

    if (data.SecretString) {
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

module.exports = getDatabaseSecrets;


