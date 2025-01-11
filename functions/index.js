import { getFirestore } from 'firebase-admin/firestore';
import * as functions from 'firebase-functions';
import admin from 'firebase-admin';

admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    databaseURL: 'https://medical-emergency-38bb9.firebaseio.com'
});
const db = getFirestore();
// Function to send notifications (implement this based on your notification service)
async function sendNotification(token, title, body) {
    const message = {
        notification: {
            title: title,
            body: body,
        },
        token: token,
    };

    return admin.messaging().send(message);
}
export const sendNotification = functions.https.onRequest((req, res) => {
  const token = req.body.token; // Get the FCM token from the request body
  const title = req.body.title;
  const body = req.body.body;
  const doctorData = req.body.doctorData;
  console.log(doctorData);
  console.log(token);
  console.log(body);
  console.log(title);
  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: {
      doctorId : doctorData.uid,
      doctorName : doctorData.firstname + " " + doctorData.lastname,
    },
    token: token,
  };
  console.log(message);
  admin.messaging().send(message)
    .then((response) => {
      console.log('Successfully sent message:', response);
      res.status(200).send('Notification sent successfully');
    })
    .catch((error) => {
      console.error('Error sending message:', error);
      res.status(500).send('Error sending notification');
    });
});

export const requestAmbulance = functions.https.onRequest(async (req, res) => {
    if (req.method !== 'POST') {
        return res.status(405).send('Method Not Allowed');
    }
    
    const { latitude, longitude, userId, name, phone, address, icNumber, description } = req.body;

    // Validate the request body
    if (!latitude || !longitude) {
        return res.status(400).json({ error: 'Missing required fields (latitude, longitude)' });
    }

    // Check if a similar request already exists
    const existingRequestSnapshot = await db.collection('ambulanceRequests')
        .where('userId', '==', userId)
        .where('latitude', '==', latitude)
        .where('longitude', '==', longitude)
        .get();

    if (!existingRequestSnapshot.empty) {
        return res.status(409).json({ error: 'A similar request already exists' });
    }

    // Create the new ambulance request
    const ambulanceRequest = {
        user_phone: phone,
        user_userId: userId,
        user_name: name,
        user_icNumber: icNumber,
        description: description,
        user_address: address,
        user_latitude: latitude,
        user_longitude: longitude,
    };

    // Save to Firestore
    try {
        const docRef = await db.collection('ambulanceRequests').add(ambulanceRequest); // Add the document and capture the reference
        ambulanceRequest.id = docRef.id; // Add the ID to the ambulanceRequest object

        // Find the nearest ambulance
        const ambulanceSnapshot = await db.collection('ambulance').get(); // Assuming you have a collection for ambulances
        let nearestAmbulance = null;
        let minDistance = Infinity;

        function haversineDistance(lat1, lon1, lat2, lon2) {
            const R = 6371; // Radius of the Earth in km
            const dLat = (lat2 - lat1) * (Math.PI / 180);
            const dLon = (lon2 - lon1) * (Math.PI / 180);
            const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                      Math.cos(lat1 * (Math.PI / 180)) * Math.cos(lat2 * (Math.PI / 180)) *
                      Math.sin(dLon / 2) * Math.sin(dLon / 2);
            const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
            return R * c; // Distance in km
        }

        ambulanceSnapshot.forEach(doc => {
            const ambulanceData = doc.data();
            const distance = haversineDistance(latitude, longitude, ambulanceData.latitude, ambulanceData.longitude);
            if (distance < minDistance) {
                minDistance = distance;
                nearestAmbulance = ambulanceData;
            }
        });

        // Update the ambulance request with the nearest ambulance details
        ambulanceRequest.selectedAmbulance = nearestAmbulance; 
        await db.collection('ambulanceRequests').doc(ambulanceRequest.id).update({
            selectedAmbulance: nearestAmbulance, // Include the entire nearestAmbulance object
            status: 'pending',
            onhold_status: 'onhold',
            documentId: ambulanceRequest.id,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        const ambulanceToken = nearestAmbulance.fcmToken; // Assuming the ambulance document has an FCM token
        console.log(ambulanceToken);

        if (nearestAmbulance && nearestAmbulance.fcmToken) {
            const message = {
                notification: {
                    title: 'New Ambulance Request',
                    body: `A new ambulance request has been made. Request ID: ${ambulanceRequest.id}`,
                },
                data: {
                    requestId: ambulanceRequest.id,
                },
                token: nearestAmbulance.fcmToken,
            };

            await admin.messaging().send(message);
            console.log('Notification sent to ambulance:', nearestAmbulance);
        } else {
            console.warn('No valid FCM token found for the nearest ambulance.');
        }

        return res.status(201).json({ message: 'Request received', data: ambulanceRequest });
    } catch (error) {
        console.error('Error saving request or finding nearest ambulance:', error);
        return res.status(500).json({ error: 'Internal Server Error' });
    }
});