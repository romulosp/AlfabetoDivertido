// Uses VS Code's built-in Node launcher to run the Android launch task.
const { spawn } = require('node:child_process');
const path = require('node:path');
const child = spawn('powershell.exe', [
  '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
  path.join(__dirname, process.argv.includes('--celular') ? 'deploy_celular.ps1' : 'launch_android.ps1'),
], { stdio: 'inherit' });
child.on('error', (error) => { console.error(error.message); process.exitCode = 1; });
child.on('exit', (code) => { process.exitCode = code ?? 1; });
