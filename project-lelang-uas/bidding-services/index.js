const express = require('express');
const mongoose = require('mongoose');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
app.use(express.json()); // Agar bisa membaca body JSON dari Postman

const server = http.createServer(app);
const io = new Server(server, { 
    cors: { origin: "*" } 
});

// Koneksi ke MongoDB 
// Ganti 'rahasiamongo123' sesuai password di .env Anda
const mongoUrl = "mongodb://root:rahasiabid123@bidding-db:27017/lelang_bidding?authSource=admin";

mongoose.connect(mongoUrl, {
    serverSelectionTimeoutMS: 5000 // Tunggu 5 detik sebelum timeout
})
    .then(() => console.log("✅ Terhubung ke MongoDB!"))
    .catch(err => console.error("❌ Gagal konek Mongo:", err));

// Schema Bidding (NoSQL)
const BidSchema = new mongoose.Schema({
    item_id: Number,     // ID Barang dari PostgreSQL
    user_id: Number,     // ID User dari MySQL
    tawaran_harga: Number,
    waktu: { type: Date, default: Date.now }
});
const Bid = mongoose.model('Bid', BidSchema);

// Endpoint Tes
app.get('/', (req, res) => {
    res.send("Bidding Service is Running and Connected to MongoDB!");
});

// Endpoint untuk Menawar (POST)
app.post('/bid', async (req, res) => {
    try {
        const { item_id, user_id, tawaran_harga } = req.body;
        
        const newBid = new Bid({ item_id, user_id, tawaran_harga });
        await newBid.save();

        // Mengirim sinyal real-time ke semua user yang menonton lelang
        io.emit('newBid', newBid);

        res.status(201).json({ 
            message: "Tawaran berhasil masuk ke MongoDB!", 
            data: newBid 
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// --- 1. Ambil Semua Riwayat Bid (Read All) --- 
// Berguna untuk admin melihat semua aktivitas lelang
app.get('/bid', async (req, res) => {
    try {
        const bids = await Bid.find().sort({ waktu: -1 }); // Urutkan dari yang terbaru
        res.json(bids);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// --- 2. Ambil Riwayat Bid untuk Satu Barang (Read by Item ID) ---
// SANGAT PENTING untuk Flutter menampilkan history penawaran di detail barang
app.get('/bid/item/:item_id', async (req, res) => {
    try {
        const { item_id } = req.params;
        const bids = await Bid.find({ item_id: item_id }).sort({ tawaran_harga: -1 });
        res.json(bids);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// --- 3. Update Bid (Update) ---
// Catatan: Biasanya dalam lelang bid tidak diedit, tapi ini berguna jika ada koreksi admin
app.put('/bid/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const updatedBid = await Bid.findByIdAndUpdate(id, req.body, { new: true });
        if (!updatedBid) return res.status(404).json({ message: "Data bid tidak ditemukan" });
        
        res.json({ message: "Bid berhasil diperbarui", data: updatedBid });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// --- 4. Hapus Bid (Delete) ---
// Berguna jika ada "bid fiktif" yang perlu dihapus oleh admin
app.delete('/bid/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const deletedBid = await Bid.findByIdAndDelete(id);
        if (!deletedBid) return res.status(404).json({ message: "Data bid tidak ditemukan" });
        
        res.json({ message: "Bid berhasil dihapus" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Jalankan server di port 3000
server.listen(3000, '0.0.0.0', () => {
    console.log('🚀 Bidding service listening on port 3000');
});