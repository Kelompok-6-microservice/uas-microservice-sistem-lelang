package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/go-redis/redis/v8"
)

var ctx = context.Background()
var rdb *redis.Client

func main() {
	// Koneksi ke Redis
	rdb = redis.NewClient(&redis.Options{
		Addr: "redis-broker:6379",
	})

	// 1. Jalankan Subscriber di Background (Goroutine)
	go func() {
		subscriber := rdb.Subscribe(ctx, "lelang_notifications")
		fmt.Println("🚀 Notification Subscriber Aktif (Listening to Redis)...")
		
		for {
			msg, err := subscriber.ReceiveMessage(ctx)
			if err != nil {
				log.Println("Error menerima pesan:", err)
				continue
			}

			// Simpan pesan ke dalam List Redis bernama 'history_notif'
			// Agar bisa dibaca oleh API nanti
			rdb.LPush(ctx, "history_notif", msg.Payload)
			
			// Batasi hanya menyimpan 50 notifikasi terakhir agar memori tidak penuh
			rdb.LTrim(ctx, "history_notif", 0, 49)

			fmt.Printf("🔔 PESAN MASUK: %s\n", msg.Payload)
		}
	}()

	// 2. HTTP Server untuk API (Agar Flutter bisa GET data)
	http.HandleFunc("/notifications", getNotificationsHandler)

	fmt.Println("📡 API Notification Service berjalan di port 8004")
	// Port 8004 adalah port internal container
	log.Fatal(http.ListenAndServe(":8004", nil))
}

// Handler untuk mengambil data notifikasi dari Redis
func getNotificationsHandler(w http.ResponseWriter, r *http.Request) {
	// Set header agar JSON dan bisa diakses Flutter (CORS)
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")

	// Ambil semua data dari list 'history_notif' di Redis
	notifications, err := rdb.LRange(ctx, "history_notif", 0, -1).Result()
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{"error": "Gagal mengambil data"})
		return
	}

	// Kirim response ke Flutter/Postman
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status": "success",
		"data":   notifications,
	})
}