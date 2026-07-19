import {
  GetParameterCommand,
  GetParametersCommand,
  SSMClient,
} from '@aws-sdk/client-ssm';

const ssmClient = new SSMClient({});

type AppSecrets = {
  databaseUrl: string;
  supabaseServiceRoleKey: string;
  groqApiKey: string;
  firebaseServiceAccount: string;
};

type SecretParameterNames = AppSecrets;

let cachedSecrets: Promise<AppSecrets> | undefined;

// Lấy value của một biến env bắt buộc trong lambda function
// Vd: DATABASE_URL_PARAMETER=/storix/prod/database-url --> return "/storix/prod/database-url"
const getRequiredEnvironmentVariable = (name: string): string => {
  const value = process.env[name];

  if (!value) {
    throw new Error(
      `Required environment variable "${name}" is not configured`,
    );
  }

  return value;
};

// Đọc toàn bộ các SSM Parameter name được cấu hình thông qua biến env
// NOTE: Lambda function phải cấu hình sẵn các biến env là SSM Parameter name cần thiết
const getSsmParameterNames = (): SecretParameterNames => {
  return {
    databaseUrl: getRequiredEnvironmentVariable('DATABASE_URL_PARAMETER'),
    supabaseServiceRoleKey: getRequiredEnvironmentVariable(
      'SUPABASE_SERVICE_ROLE_PARAMETER',
    ),
    groqApiKey: getRequiredEnvironmentVariable('GROQ_API_KEY_PARAMETER'),
    firebaseServiceAccount: getRequiredEnvironmentVariable(
      'FIREBASE_SERVICE_ACCOUNT_PARAMETER',
    ),
  };
};

const getParameterValue = (
  parameters: Map<string, string>,
  parameterName: string,
): string => {
  const parameterValue = parameters.get(parameterName);

  if (parameterValue === undefined) {
    throw new Error(
      `Required SSM parameter "${parameterName}" was not returned`,
    );
  }

  return parameterValue;
};

const loadSecrets = async (): Promise<AppSecrets> => {
  const names = getSsmParameterNames();

  const parameterNames = [
    names.databaseUrl,
    names.supabaseServiceRoleKey,
    names.groqApiKey,
    names.firebaseServiceAccount,
  ];

  const result = await ssmClient.send(
    new GetParametersCommand({
      Names: parameterNames,
      WithDecryption: true,
    }),
  );

  if (result.InvalidParameters && result.InvalidParameters.length > 0) {
    throw new Error(
      `Some required SSM parameters could not be loaded: ${result.InvalidParameters.join(
        ', ',
      )}`,
    );
  }

  const parameters = new Map<string, string>();

  for (const parameter of result.Parameters ?? []) {
    if (parameter.Name !== undefined && parameter.Value !== undefined) {
      parameters.set(parameter.Name, parameter.Value);
    }
  }

  return {
    databaseUrl: getParameterValue(parameters, names.databaseUrl),
    supabaseServiceRoleKey: getParameterValue(
      parameters,
      names.supabaseServiceRoleKey,
    ),
    groqApiKey: getParameterValue(parameters, names.groqApiKey),
    firebaseServiceAccount: getParameterValue(
      parameters,
      names.firebaseServiceAccount,
    ),
  };
};

/**
 * Lấy toàn bộ application secrets.
 *
 * Secrets chỉ được tải từ AWS SSM đúng một lần
 * trong mỗi Lambda execution environment.
 *
 * Những lần gọi tiếp theo sẽ dùng lại Promise đã cache
 * để tránh phát sinh request SSM không cần thiết.
 *
 * Nếu lần tải đầu tiên thất bại,
 * cache sẽ được xoá để cho phép retry
 * ở lần gọi kế tiếp.
 */
export const getSecrets = (): Promise<AppSecrets> => {
  if (!cachedSecrets) {
    // nếu cache lỗi, reset cache
    cachedSecrets = loadSecrets().catch((error: unknown) => {
      cachedSecrets = undefined;

      throw error;
    });
  }

  return cachedSecrets;
};

export const loadSecretsToEnvironment = async (): Promise<void> => {
  const secrets = await getSecrets();

  process.env.DATABASE_URL = secrets.databaseUrl;
  process.env.SUPABASE_SERVICE_ROLE_KEY = secrets.supabaseServiceRoleKey;
  process.env.GROQ_API_KEY = secrets.groqApiKey;
  process.env.FIREBASE_SERVICE_ACCOUNT = secrets.firebaseServiceAccount;
};

// Lấy trực tiếp value 1 Ssm Parameter và cache
export const getDirectSsmParameter = (
  parameterName: string,
): Promise<string> => {
  const directParameterCache = new Map<string, Promise<string>>();

  const cachedParameter = directParameterCache.get(parameterName);

  if (cachedParameter) {
    return cachedParameter;
  }

  const parameterPromise = ssmClient
    .send(
      new GetParameterCommand({
        Name: parameterName,
        WithDecryption: true,
      }),
    )
    .then((response) => {
      if (!response.Parameter?.Value) {
        throw new Error(`SSM parameter "${parameterName}" is empty`);
      }

      return response.Parameter.Value;
    })
    .catch((error: unknown) => {
      directParameterCache.delete(parameterName);

      throw error;
    });

  directParameterCache.set(parameterName, parameterPromise);

  return parameterPromise;
};
