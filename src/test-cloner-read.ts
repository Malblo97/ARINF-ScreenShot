// src/test-cloner-read.ts
import { ScriptCloner } from './patterns/prototype/ScriptCloner'

async function main() {
  const cloner = new ScriptCloner()
  const script = await cloner.readFullScript(1)
  console.log(JSON.stringify(script, null, 2))
}
main()