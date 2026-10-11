export const repositoryUrl = 'https://github.com/mpi-informatique/enseignement';

export const githubEditUrl = (file: string): string => `${repositoryUrl}/edit/main/${file.split('/').map(encodeURIComponent).join('/')}`;
