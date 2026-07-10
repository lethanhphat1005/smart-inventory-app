export type DependencyStatus = 'up' | 'down';

export type HealthDependency = {
  status: DependencyStatus;
  latencyMs?: number;
  message?: string;
};
