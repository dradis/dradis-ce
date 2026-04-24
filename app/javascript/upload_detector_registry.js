const detectors = []

export function register({ name, match }) {
  if (detectors.some(d => d.name === name)) {
    console.warn(`[upload_detector_registry] Duplicate detector: ${name}`)
    return
  }
  detectors.push({ name, match })
}

export function detect(sample, filename) {
  const matches = detectors.filter(d => {
    try { return d.match(sample, filename) } catch (_e) { return false }
  })
  if (matches.length > 1) {
    console.warn(`[upload_detector_registry] Multiple detectors matched for "${filename}": ${matches.map(d => d.name).join(', ')}. Using first match.`)
  }
  return matches.length > 0 ? matches[0].name : null
}

export function all() {
  return detectors.slice()
}
