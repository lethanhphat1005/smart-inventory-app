export const getRandomMessage = (templates: string[]): string => {
  if (!templates || templates.length === 0) {
    return '';
  }

  const randomIndex = Math.floor(Math.random() * templates.length);

  return templates[randomIndex]!;
};
