# Local AI Client

This repository is for an iOS client that communicates with a local AI running on shared network. It is coded in Swift, using SwiftUI and follows SOLID principles. It was a fun POC for learning how to stand up and use local LLMs. In my use case, I installed DeepSeek on my Mac Mini. Steps for installation are as follows. 


## **Step-by-Step Installation Guide for DeepSeek on Mac Mini**

### **Prerequisites**
Before starting, ensure your Mac mini has:
- macOS 10.15 (Catalina) or later
- At least 8GB RAM (16GB recommended for better performance)
- At least 10-50GB of free storage (depending on which model you choose)

### ** Install local AI using Terminal**

#### **Step 1: Install Ollama**
Ollama is the framework that runs AI models locally on your Mac.

1. Open **Terminal** (press `Cmd + Space`, type "Terminal", and press Enter)
2. Visit https://ollama.com and click "Download for macOS"
3. Once downloaded, open the `.dmg` file from your Downloads folder
4. Drag the Ollama app to your Applications folder
5. Open Ollama from Applications

Alternatively, you can install via command line:
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

6. Verify installation by typing in Terminal:
```bash
ollama --version
```

#### **Step 2: Download DeepSeek Model**

Dhoose which DeepSeek model to install based on your Mac Mini's capabilities:

- **8B model** (recommended for most users): 5GB, fast and efficient
- **14B model**: 8GB, balanced performance
- **32B model**: 19GB, better quality
- **70B model**: 43GB, best quality but requires more RAM

Run one of these commands in Terminal:
```bash
ollama run deepseek-r1:8b
```

Or for other sizes:
```bash
ollama run deepseek-r1:14b
ollama run deepseek-r1:32b
ollama run deepseek-r1:70b
```

The model will download (this may take 10-30 minutes depending on size and internet speed), and then you'll be able to chat directly in the Terminal!


## **How to Use DeepSeek Once Installed**

### **Using Terminal**

After installation, simply type:
```bash
ollama run deepseek-r1:8b
```

Then you can start chatting:
```
>>> What is the capital of France?
>>> Write a Python function to calculate fibonacci numbers
>>> Explain quantum computing in simple terms
```

To exit, type:
```
/bye
```

## **Useful Commands**

**List all installed models:**
```bash
ollama list
```

**Remove a model to free up space:**
```bash
ollama rm deepseek-r1:8b
```

**Switch between models:**
```bash
ollama run deepseek-r1:14b
```

**Pull a model without running it:**
```bash
ollama pull deepseek-r1:8b
```


## **Setting Up DeepSeek as a Local Network API**

### **Step 1: Configure Ollama to Accept Network Connections**

By default, Ollama only accepts connections from localhost. You need to configure it to accept connections from your local network.

#### **Configure Local Network Connections:**

1. Open **Terminal**
2. Set the environment variable to bind Ollama to all network interfaces:

```bash
launchctl setenv OLLAMA_HOST "0.0.0.0:11434"
```

3. Restart Ollama:
   - Quit Ollama completely (right-click the Ollama icon in menu bar → Quit)
   - Reopen Ollama from Applications

#### **Alternative Method (Persistent Configuration):**

Create a launch agent to make this permanent:

```bash
mkdir -p ~/Library/LaunchAgents
```

Create a file at `~/Library/LaunchAgents/com.ollama.environment.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ollama.environment</string>
    <key>ProgramArguments</key>
    <array>
        <string>sh</string>
        <string>-c</string>
        <string>launchctl setenv OLLAMA_HOST 0.0.0.0:11434</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
```

Then load it:
```bash
launchctl load ~/Library/LaunchAgents/com.ollama.environment.plist
```

### **Step 2: Find Your Mac Mini's Local IP Address**

1. Click the Apple menu → **System Settings**
2. Click **Network**
3. Select your active connection (Wi-Fi or Ethernet)
4. Look for your **IP address** (it will look like `192.168.1.xxx` or `10.0.0.xxx`)

Alternative via Terminal:
```bash
ipconfig getifaddr en0  # for Wi-Fi
# or
ipconfig getifaddr en1  # for Ethernet
```


## **Using the Ollama API from iOS Client AI App**

With Ollama API available, you'll need to update `baseURL` in `DeepSeekAPIService` to the Olama API Endpoint as follows:

### **API Endpoint Structure**

The Ollama API is available at:
```
http://YOUR_MAC_IP:11434
```

For example: `http://192.168.1.100:11434`

### **Key API Endpoints**

**Generate a response (streaming):**
```
POST http://YOUR_MAC_IP:11434/api/generate
```

**Generate a response (non-streaming):**
```
POST http://YOUR_MAC_IP:11434/api/generate
```

**Chat endpoint (maintains conversation history):**
```
POST http://YOUR_MAC_IP:11434/api/chat
```

**List available models:**
```
GET http://YOUR_MAC_IP:11434/api/tags
```


## **Testing the API**

### **From Terminal:**
```bash
curl http://YOUR_MAC_IP:11434/api/generate -d '{
  "model": "deepseek-r1:8b",
  "prompt": "Why is the sky blue?",
  "stream": false
}'
```

### **Check Available Models:**
```bash
curl http://YOUR_MAC_IP:11434/api/tags
```


## **Troubleshooting**

**Can't connect from iPhone:**
- Verify Mac and iPhone are on same Wi-Fi network
- Check Mac's IP address is correct
- Ensure Ollama is running on Mac
- Try pinging your Mac from another device: `ping YOUR_MAC_IP`
- Check macOS Firewall settings (System Settings → Network → Firewall)

**Slow responses:**
- Use smaller models (8B or 14B) for faster responses
- Close unnecessary apps on Mac to free RAM
- Consider response time will be slower than cloud APIs


