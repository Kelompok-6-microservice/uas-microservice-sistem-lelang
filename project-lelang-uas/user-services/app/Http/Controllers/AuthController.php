<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        // 1. Validasi Input (Menambahkan foto sebagai optional)
        $this->validate($request, [
            'name'     => 'required|string',
            'email'    => 'required|email|unique:users',
            'password' => 'required|min:6',
            'foto'     => 'nullable|string' // Bisa dikosongkan atau diisi URL string
        ]);

        // 2. Simpan ke Database
        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'foto'     => $request->foto, // Menangkap input foto
            'password' => Hash::make($request->password),
        ]);

        return response()->json([
            'message' => 'User berhasil didaftarkan!',
            'user'    => $user
        ], 201);
    }

    public function login(Request $request)
    {
        $this->validate($request, [
            'email'    => 'required|email',
            'password' => 'required'
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Login Gagal!'], 401);
        }

        // Buat token acak
        $token = bin2hex(random_bytes(30));
        $user->update(['api_token' => $token]);

        return response()->json([
            'message' => 'Login Berhasil!',
            'user_id' => $user->id,
            'token'   => $token,
            'user'    => $user // Mengembalikan data user lengkap termasuk foto
        ]);
    }

    // 1. Ambil semua User
    public function index()
    {
        return response()->json(User::all(), 200);
    }

    // 2. Ambil satu User berdasarkan ID
    public function show($id)
    {
        $user = User::find($id);
        if (!$user) {
            return response()->json(['message' => 'User tidak ditemukan'], 404);
        }
        return response()->json($user, 200);
    }

    // 3. Update User (Termasuk update foto)
    public function update(Request $request, $id)
    {
        $user = User::find($id);
        if (!$user) {
            return response()->json(['message' => 'User tidak ditemukan'], 404);
        }

        $this->validate($request, [
            'name'  => 'string',
            'email' => 'email|unique:users,email,' . $user->id,
            'foto'  => 'nullable|string' // Memungkinkan update URL foto
        ]);

        $user->update($request->all());

        return response()->json([
            'message' => 'Profil berhasil diperbarui!',
            'user'    => $user
        ], 200);
    }

    // 4. Hapus User
    public function destroy($id)
    {
        $user = User::find($id);
        if (!$user) {
            return response()->json(['message' => 'User tidak ditemukan'], 404);
        }

        $user->delete();
        return response()->json(['message' => 'Akun berhasil dihapus'], 200);
    }
}