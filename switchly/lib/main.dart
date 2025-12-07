import 'package:flutter/material.dart';

void main() {
  runApp(const BluetoothControlApp());
}

// Main Application 
class BluetoothControlApp extends StatelessWidget {
  const BluetoothControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arduino Bluetooth Control',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const ControlScreen(),
    );
  }
}

// Manages the state of the buttons
class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  // Bluetooth Variables (Placeholders for flutter_bluetooth_serial)
  // BluetoothConnection? connection;
  bool isConnected = false; 
  String connectionStatus = 'DISCONNECTED';

  // Map to store the ON/OFF state of each load. 0=OFF, 1=ON.
  Map<int, bool> loadStates = {
    1: false,
    2: false,
    3: false,
    4: false,
  };
  bool isMasterNormal = true; // 'E' command state

  // --- Core Bluetooth Logic ---
  // Placeholder function to send commands. In a live app, this handles the serial write.
  void _sendCommand(String command) {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Not connected to HC-05.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
        
    // DEBUG: Print the sent command to the console
    print('Bluetooth Sent: $command');

    // UI Feedback: Show a temporary snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Command sent: $command'),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }
  
  // Placeholder for the actual connection function
  // In a real app, this would use BluetoothDiscoverySession and BluetoothConnection.
  void _connectToDevice() async {
    // Simulate connection attempt
    setState(() {
      connectionStatus = 'CONNECTING...';
    });
    
    await Future.delayed(const Duration(seconds: 2)); // Simulate connection time

    setState(() {
      isConnected = true; // Assume success for this demo
      connectionStatus = 'CONNECTED to HC-05';
      
      // IMPORTANT: Send the Master Normal command ('E') immediately after connecting
      // This ensures the Arduino is ready to accept individual load toggles.
      _setMasterMode('E');
    });
  }


  // --- Toggle and State Management Logic ---
  void _toggleLoad(int loadIndex) {
    if (!isMasterNormal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: System is in Shutdown Mode (send "E" first)'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    // 1. Send the single-character command (e.g., '1', '2', '3', '4')
    _sendCommand(loadIndex.toString());

    // 2. Update the local UI state
    setState(() {
      loadStates[loadIndex] = !loadStates[loadIndex]!;
    });
  }

  // --- Master Control Logic ---
  void _setMasterMode(String command) {
    // 'E' = Normal Mode, 'e' = Shutdown Mode
    _sendCommand(command);

    setState(() {
      isMasterNormal = (command == 'E');
      
      if (!isMasterNormal) {
        // Force all loads OFF when entering Shutdown Mode
        loadStates.updateAll((key, value) => false);
      }
    });
  }

  // --- UI Builder Functions ---
  Widget _buildLoadButton(int index, String label) {
    bool isOn = loadStates[index]!;
    
    return ElevatedButton(
      onPressed: () => _toggleLoad(index),
      style: ElevatedButton.styleFrom(
        foregroundColor: isOn ? Colors.white : Colors.grey.shade800,
        backgroundColor: isOn ? Colors.green.shade600 : Colors.grey.shade200,
        padding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            isOn ? '(ON)' : '(OFF)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isOn ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('4-Channel Arduino Control'),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Connection Area
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isConnected ? Colors.blue.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isConnected ? Colors.blue.shade300 : Colors.red.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bluetooth Status: $connectionStatus',
                    style: TextStyle(
                      color: isConnected ? Colors.blue.shade800 : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isConnected ? null : _connectToDevice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isConnected ? Colors.grey : Colors.blue.shade500,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isConnected ? 'Connected' : 'Connect'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            // Operational Status 
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMasterNormal ? Colors.lightGreen.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isMasterNormal ? Colors.green.shade300 : Colors.red.shade300),
              ),
              child: Text(
                isMasterNormal ? 'Operational Mode: NORMAL' : 'Operational Mode: SHUTDOWN',
                style: TextStyle(
                  color: isMasterNormal ? Colors.green.shade800 : Colors.red.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            
            const SizedBox(height: 24),
            const Text(
              'Individual Load Control',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const Divider(),

            // Relay Buttons Grid (4x)
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                _buildLoadButton(1, 'Load 1 (Pin 4)'),
                _buildLoadButton(2, 'Load 2 (Pin 5)'),
                _buildLoadButton(3, 'Load 3 (Pin 6)'),
                _buildLoadButton(4, 'Load 4 (Pin 7)'),
              ],
            ),

            const SizedBox(height: 32),
            const Text(
              'Master Control Commands',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const Divider(),

            // Master Control Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _setMasterMode('E'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Master Normal (E)', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _setMasterMode('e'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Master Shutdown (e)', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}