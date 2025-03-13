const express = require('express');
const path = require('path');
const { exec } = require('child_process');
const app = express();
const port = process.env.PORT || 5000;

// Enable JSON parsing
app.use(express.json());

// Serve static files from the 'web' directory
app.use(express.static(path.join(__dirname, 'web')));

// API endpoint for building the Flutter web app
app.post('/api/build', (req, res) => {
  console.log('Received request to build the Flutter web application');
  
  // Execute the build script
  exec('./flutter_build.sh', (error, stdout, stderr) => {
    if (error) {
      console.error(`Error executing build script: ${error.message}`);
      return res.status(500).json({ 
        success: false, 
        message: 'Build failed',
        error: error.message,
        details: stderr
      });
    }
    
    console.log(`Build output: ${stdout}`);
    
    if (stderr) {
      console.error(`Build stderr: ${stderr}`);
    }
    
    res.json({ 
      success: true, 
      message: 'Build completed successfully',
      output: stdout
    });
  });
});

// API endpoint for checking status
app.get('/api/status', (req, res) => {
  // Check if web directory exists and contains index.html
  const webDirExists = require('fs').existsSync(path.join(__dirname, 'web'));
  const indexExists = webDirExists && 
    require('fs').existsSync(path.join(__dirname, 'web', 'index.html'));
  
  res.json({
    status: 'ok',
    webDirectoryExists: webDirExists,
    indexFileExists: indexExists,
    message: indexExists 
      ? 'Flutter web application is ready to serve' 
      : 'Flutter web application needs to be built'
  });
});

// Handle all routes by sending the index.html
app.get('*', (req, res) => {
  // Check if web/index.html exists, if not show a placeholder
  const indexPath = path.join(__dirname, 'web', 'index.html');
  
  if (require('fs').existsSync(indexPath)) {
    res.sendFile(indexPath);
  } else {
    res.send(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>Smart Habit Tracker - Setup</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            background-color: #f5f5f5;
          }
          .container {
            text-align: center;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            background-color: white;
            max-width: 600px;
          }
          h1 {
            color: #1976d2;
          }
          button {
            background-color: #1976d2;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 20px;
          }
          button:hover {
            background-color: #1565c0;
          }
          .spinner {
            border: 4px solid rgba(0, 0, 0, 0.1);
            border-radius: 50%;
            border-top: 4px solid #1976d2;
            width: 30px;
            height: 30px;
            animation: spin 1s linear infinite;
            margin: 20px auto;
            display: none;
          }
          @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
          }
          #output {
            margin-top: 20px;
            padding: 10px;
            background-color: #f0f0f0;
            border-radius: 4px;
            text-align: left;
            max-height: 200px;
            overflow-y: auto;
            white-space: pre-wrap;
            display: none;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>Smart Habit Tracker</h1>
          <p>The Flutter web application needs to be built before it can be used.</p>
          <p>Click the button below to build the application:</p>
          
          <button id="buildButton" onclick="buildApp()">Build Application</button>
          
          <div id="spinner" class="spinner"></div>
          
          <div id="output"></div>
        </div>
        
        <script>
          function buildApp() {
            const button = document.getElementById('buildButton');
            const spinner = document.getElementById('spinner');
            const output = document.getElementById('output');
            
            button.disabled = true;
            spinner.style.display = 'block';
            output.style.display = 'block';
            output.textContent = 'Building application...\n';
            
            fetch('/api/build', {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json'
              }
            })
            .then(response => response.json())
            .then(data => {
              spinner.style.display = 'none';
              
              if (data.success) {
                output.textContent += 'Build completed successfully!\n';
                output.textContent += data.output;
                output.textContent += '\nReloading page in 5 seconds...';
                
                setTimeout(() => {
                  window.location.reload();
                }, 5000);
              } else {
                button.disabled = false;
                output.textContent += 'Build failed: ' + data.message + '\n';
                if (data.details) {
                  output.textContent += data.details;
                }
              }
            })
            .catch(error => {
              button.disabled = false;
              spinner.style.display = 'none';
              output.textContent += 'Error: ' + error.message;
            });
          }
        </script>
      </body>
      </html>
    `);
  }
});

// Start the server
app.listen(port, '0.0.0.0', () => {
  console.log(`Flutter Web Server running at http://0.0.0.0:${port}`);
  
  // Check if web directory exists
  const webDirExists = require('fs').existsSync(path.join(__dirname, 'web'));
  const indexExists = webDirExists && 
    require('fs').existsSync(path.join(__dirname, 'web', 'index.html'));
  
  if (indexExists) {
    console.log('Serving the Flutter web application');
  } else {
    console.log('Flutter web application needs to be built. Visit the site to build it.');
  }
});