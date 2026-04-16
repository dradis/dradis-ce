// Shared utilities for inline thread text matching and form building.

// Find `needle` in `haystack` allowing whitespace runs in the needle
// to match any whitespace run in the haystack. Returns { start, end }
// positions in the original haystack, or null.
function fuzzyIndexOf(haystack, needle) {
  const parts = needle.split(/\s+/).map(
    s => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  );
  if (parts.length < 2) return null;

  const pattern = new RegExp(parts.join('\\s+'));
  const match = haystack.match(pattern);
  if (!match) return null;

  return { start: match.index, end: match.index + match[0].length };
}
