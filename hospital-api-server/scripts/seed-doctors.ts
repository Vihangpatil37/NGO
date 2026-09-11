import mongoose from 'mongoose';
import bcrypt from 'bcrypt';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../.env') });

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/hospital-queue';

// Seed doctors — in production, read credentials from env vars or secure config
const SEED_DOCTORS = [
  {
    phoneNumber: '9876543210',
    name: 'Dr. Amit Patel',
    specialization: 'General Medicine',
    pin: process.env.SEED_DOCTOR_PASSWORD || '123456',
  },
];

async function seedDoctors() {
  await mongoose.connect(MONGODB_URI);
  console.log('Connected to MongoDB');

  // Import model after connection
  const { Doctor } = await import('../src/models/Doctor');

  // Ensure collection exists and index is built
  await Doctor.init();
  // We should also ensure old unique indexes (like doctorId) are dropped, 
  // but for a clean start, we can just sync indexes.
  await Doctor.syncIndexes();

  for (const doc of SEED_DOCTORS) {
    const existing = await Doctor.findOne({ phoneNumber: doc.phoneNumber });
    if (existing) {
      console.log(`Doctor with phone ${doc.phoneNumber} already exists, skipping`);
      continue;
    }

    const pinHash = await bcrypt.hash(doc.pin, 12);
    await Doctor.create({
      phoneNumber: doc.phoneNumber,
      name: doc.name,
      specialization: doc.specialization,
      pinHash,
      isActive: true,
    });
    console.log(`Created doctor: ${doc.phoneNumber} (${doc.name})`);
  }

  await mongoose.disconnect();
  console.log('Seed complete');
}

seedDoctors().catch(console.error);
