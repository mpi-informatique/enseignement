// Le mode privé ou un quota épuisé ne doivent pas empêcher l'édition.
export function stored(key: string): string | null {
  try { return localStorage.getItem(`exercices:${key}`); } catch { return null; }
}

export function store(key: string, value: string | null): boolean {
  try {
    if (value === null) localStorage.removeItem(`exercices:${key}`);
    else localStorage.setItem(`exercices:${key}`, value);
    return true;
  } catch { return false; }
}
