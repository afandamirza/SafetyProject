<?php

require __DIR__ . '/vendor/autoload.php'; // Load Composer's autoload file
use Google\Cloud\Firestore\FirestoreClient;
use Google\Cloud\Storage\StorageClient;
use Google\Cloud\Core\ServiceBuilder;

// Firebase credentials
$serviceAccountPath = '../safetyreportproject-firebase-adminsdk-fhskx-a449059455.json';
$storageBucketName = 'safetyreportproject.appspot.com';

// Initialize Firebase SDK
$firebase = (new ServiceBuilder([
    'keyFilePath' => $serviceAccountPath,
]))->storage()->bucket($storageBucketName);

$firestore = new FirestoreClient([
    'keyFilePath' => $serviceAccountPath,
]);

// Helper function to generate UUID
function generateUUID() {
    return bin2hex(random_bytes(16));
}

// Handle the file upload
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_FILES['Image']) && $_FILES['Image']['error'] === UPLOAD_ERR_OK) {
        $image = $_FILES['Image'];
        $latitude = $_POST['Latitude'];
        $longitude = $_POST['Longitude'];
        $date = $_POST['Date'];
        $time = $_POST['Time'];
        $details = $_POST['Details'];

        try {
            // Generate a unique filename
            $filename = generateUUID() . '-' . basename($image['name']);
            
            // Upload the file to Firebase Storage
            $object = $firebase->upload(
                fopen($image['tmp_name'], 'r'),
                [
                    'name' => $filename,
                    'metadata' => [
                        'contentType' => $image['type'],
                    ],
                ]
            );

            // Get the public URL of the uploaded file
            $photoURL = $object->signedUrl(new DateTime('2500-03-01'));

            // Store data in Firestore
            $firestore->collection('SafetyReport')->add([
                'photoURL' => $photoURL,
                'Latitude' => $latitude,
                'Longitude' => $longitude,
                'Date' => $date,
                'Time' => $time,
                'Details' => $details,
            ]);

            echo json_encode([
                'message' => 'Data added successfully',
                'photoURL' => $photoURL,
            ]);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to upload file and save data: ' . $e->getMessage()]);
        }

    } else {
        http_response_code(400);
        echo json_encode(['error' => 'No file uploaded or there was an upload error.']);
    }
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Invalid request method.']);
}
