const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

exports.sendOrderNotification = onDocumentCreated(
    "orders/{orderId}",
    async (event) => {
      const order = event.data.data();
      const db = getFirestore();
      const tokensSnapshot = await db.collection("admin_tokens").get();
      const tokens = tokensSnapshot.docs.map((doc) => doc.data().token);
      if (tokens.length === 0) {
        console.log("❌ No admin tokens found.");
        return;
      } const message = {
        notification: {
          title: "🚨 New Order Received",
          body: `Order ID: ${order.orderId} - Total: NRS ${order.totalPrice}`,
        },
        android: {
          notification: {
            sound: "default",
          },
        },
        tokens,
      }; try {
        const response = await getMessaging().sendMulticast(message);
        console.log(`✅ ${response.successCount} messages sent successfully`);
      } catch (error) {
        console.error("❌ Error sending FCM:", error);
      }
    });
