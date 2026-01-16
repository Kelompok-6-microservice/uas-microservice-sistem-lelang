from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from pydantic import BaseModel
from datetime import datetime
from typing import Optional
import os

# Konfigurasi Database PostgreSQL
DATABASE_URL = "postgresql://postgres:rahasiabrang123@item-db:5432/lelang_item"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# --- 1. MODEL DATABASE (DITAMBAH KOLOM BARU) ---
class Item(Base):
    __tablename__ = "items"
    id = Column(Integer, primary_key=True, index=True)
    nama_barang = Column(String)
    deskripsi = Column(String)
    harga_awal = Column(Float)
    owner_id = Column(Integer)
    # Tambahan kolom untuk Gambar dan Waktu
    image_url = Column(String, nullable=True) 
    end_time = Column(DateTime, nullable=True) 

# Buat tabel/update tabel
Base.metadata.create_all(bind=engine)

app = FastAPI()

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- 2. SCHEMA VALIDASI (DITAMBAH FIELD BARU) ---
class ItemCreate(BaseModel):
    nama_barang: str
    deskripsi: str
    harga_awal: float
    owner_id: int
    image_url: Optional[str] = None
    end_time: datetime # Flutter akan mengirim format ISO String

@app.get("/")
def read_root():
    return {"message": "Item Service with Timer & Image is Running!"}

# --- 3. ENDPOINT CREATE (DENGAN LOGIKA SIMPAN) ---
@app.post("/items", status_code=201)
def create_item(item: ItemCreate, db: Session = Depends(get_db)):
    new_item = Item(
        nama_barang=item.nama_barang,
        deskripsi=item.deskripsi,
        harga_awal=item.harga_awal,
        owner_id=item.owner_id,
        image_url=item.image_url,
        end_time=item.end_time
    )
    db.add(new_item)
    db.commit()
    db.refresh(new_item)
    return {"message": "Barang lelang berhasil dipublikasikan!", "data": new_item}

# --- 4. AMBIL SEMUA BARANG ---
@app.get("/items")
def get_all_items(db: Session = Depends(get_db)):
    # Mengurutkan berdasarkan yang terbaru
    items = db.query(Item).order_by(Item.id.desc()).all()
    return items

# --- 5. AMBIL SATU BARANG ---
@app.get("/items/{item_id}")
def get_item(item_id: int, db: Session = Depends(get_db)):
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Barang tidak ditemukan")
    return item

# --- 6. UPDATE BARANG ---
@app.put("/items/{item_id}")
def update_item(item_id: int, updated_data: ItemCreate, db: Session = Depends(get_db)):
    item_query = db.query(Item).filter(Item.id == item_id)
    item = item_query.first()
    
    if not item:
        raise HTTPException(status_code=404, detail="Barang tidak ditemukan")
    
    item_query.update(updated_data.dict(), synchronize_session=False)
    db.commit()
    return {"message": "Data lelang diperbarui", "data": item_query.first()}

# --- 7. HAPUS BARANG ---
@app.delete("/items/{item_id}")
def delete_item(item_id: int, db: Session = Depends(get_db)):
    item_query = db.query(Item).filter(Item.id == item_id)
    if not item_query.first():
        raise HTTPException(status_code=404, detail="Barang tidak ditemukan")
    
    item_query.delete(synchronize_session=False)
    db.commit()
    return {"message": "Barang dihapus dari lelang"}