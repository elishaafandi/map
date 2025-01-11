import 'package:flutter/material.dart';

class WriteYourFeedback extends StatefulWidget {
  @override
  _WriteYourFeedbackState createState() => _WriteYourFeedbackState();
}

class _WriteYourFeedbackState extends State<WriteYourFeedback> {
  int _rating = 0; // Star rating
  bool _imagePicked = false; // Flag to simulate image selection

  // Function to simulate picking an image
  void _pickImage() {
    setState(() {
      _imagePicked = true; // Simulate the image being picked
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write Your Feedback'),
        backgroundColor: Colors.teal.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feedback Form',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Your Feedback',
                hintText: 'Enter your feedback here',
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            // Star Rating
            Text(
              'Rate Your Experience',
              style: TextStyle(fontSize: 16, color: Colors.blue[800]),
            ),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1; // Update the rating
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 16),
            // Upload Photo Section (Simulation)
            Text(
              'Upload a Photo (Optional)',
              style: TextStyle(fontSize: 16, color: Colors.blue[800]),
            ),
            SizedBox(height: 8),
            _imagePicked
                ? Column(
                    children: [
                      // Simulated image - placeholder image from assets
                      Image.asset(
                        'assets/placeholder_image.png', // Add your placeholder image in the assets folder
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: Text('Change Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Pick an Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add your feedback submission logic here
                Navigator.pop(context);
              },
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
