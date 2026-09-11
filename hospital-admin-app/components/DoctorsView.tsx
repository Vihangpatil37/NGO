import { useState, useEffect } from 'react';
import { getDoctors, addDoctor, updateDoctor, deleteDoctor } from '../lib/api';
import { UserPlus, CheckCircle, XCircle, Clock, Edit2, Trash2 } from 'lucide-react';

interface Doctor {
  _id: string;
  name: string;
  specialization?: string;
  phoneNumber: string;
  isActive: boolean;
  availability: { status: 'coming' | 'not_coming'; respondedAt: string }[];
}

export default function DoctorsView() {
  const [doctors, setDoctors] = useState<Doctor[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isEditMode, setIsEditMode] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);

  // Form state
  const [name, setName] = useState('');
  const [specialization, setSpecialization] = useState('');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [pin, setPin] = useState('');
  const [formError, setFormError] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const fetchDoctors = async () => {
    try {
      const res = await getDoctors();
      setDoctors(res.data || []);
      setError('');
    } catch (err) {
      setError('Failed to fetch doctors.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDoctors();
  }, []);

  const openAddModal = () => {
    setIsEditMode(false);
    setEditingId(null);
    setName('');
    setSpecialization('');
    setPhoneNumber('');
    setPin('');
    setFormError('');
    setIsModalOpen(true);
  };

  const openEditModal = (doc: Doctor) => {
    setIsEditMode(true);
    setEditingId(doc._id);
    setName(doc.name);
    setSpecialization(doc.specialization || '');
    setPhoneNumber(doc.phoneNumber);
    setPin(''); // Leave blank to not update PIN
    setFormError('');
    setIsModalOpen(true);
  };

  const handleDelete = async (id: string, docName: string) => {
    if (!window.confirm(`Are you sure you want to permanently remove Dr. ${docName}?`)) {
      return;
    }
    try {
      await deleteDoctor(id);
      fetchDoctors();
    } catch (err: any) {
      alert(err.message || 'Failed to delete doctor.');
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError('');

    if (phoneNumber.length !== 10) {
      setFormError('Phone number must be exactly 10 digits.');
      return;
    }
    
    // In edit mode, PIN is optional. If provided, must be 6 digits.
    if (isEditMode) {
      if (pin.length > 0 && pin.length !== 6) {
        setFormError('New PIN must be exactly 6 digits.');
        return;
      }
    } else {
      if (pin.length !== 6) {
        setFormError('PIN must be exactly 6 digits.');
        return;
      }
    }

    setIsSubmitting(true);
    try {
      if (isEditMode && editingId) {
        const updates: any = { name, specialization, phoneNumber };
        if (pin) updates.pin = pin;
        await updateDoctor(editingId, updates);
      } else {
        await addDoctor({ name, specialization, phoneNumber, pin });
      }
      setIsModalOpen(false);
      fetchDoctors();
    } catch (err: any) {
      setFormError(err.message || `Failed to ${isEditMode ? 'update' : 'add'} doctor.`);
    } finally {
      setIsSubmitting(false);
    }
  };

  if (loading) return <div className="p-6 text-center text-[var(--ink-muted)]">Loading...</div>;
  if (error) return <div className="p-6 text-center text-[var(--danger)]">{error}</div>;

  return (
    <div className="p-4 space-y-4">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-xl font-semibold">Doctors List</h2>
        <button onClick={openAddModal} className="btn-primary flex items-center gap-2">
          <UserPlus size={18} />
          <span>Add Doctor</span>
        </button>
      </div>

      <div className="space-y-3">
        {doctors.length === 0 ? (
          <p className="text-[var(--ink-muted)] text-center py-4">No doctors found.</p>
        ) : (
          doctors.map((doc) => {
            const currentAvailability = doc.availability?.[0];
            return (
              <div key={doc._id} className="bg-[var(--surface)] border border-[var(--border)] rounded-lg p-4 flex flex-col md:flex-row justify-between md:items-center gap-4">
                <div>
                  <h3 className="font-bold text-lg">{doc.name}</h3>
                  {doc.specialization && <p className="text-sm text-[var(--ink-muted)]">{doc.specialization}</p>}
                  <p className="text-sm text-[var(--ink-muted)] mt-1">Phone: {doc.phoneNumber}</p>
                </div>
                
                <div className="flex items-center gap-4">
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-medium text-[var(--ink-muted)]">Today:</span>
                    {currentAvailability ? (
                      currentAvailability.status === 'coming' ? (
                        <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800 border border-green-200">
                          <CheckCircle size={16} /> Coming
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-sm font-medium bg-red-100 text-red-800 border border-red-200">
                          <XCircle size={16} /> Not Coming
                        </span>
                      )
                    ) : (
                      <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-sm font-medium bg-yellow-100 text-yellow-800 border border-yellow-200">
                        <Clock size={16} /> No Response
                      </span>
                    )}
                  </div>
                  
                  <div className="flex items-center gap-1 ml-2 pl-4 border-l border-[var(--border)]">
                    <button 
                      onClick={() => openEditModal(doc)}
                      className="p-2 text-[var(--ink-muted)] hover:text-blue-600 transition-colors"
                      title="Edit Doctor"
                    >
                      <Edit2 size={18} />
                    </button>
                    <button 
                      onClick={() => handleDelete(doc._id, doc.name)}
                      className="p-2 text-[var(--ink-muted)] hover:text-red-600 transition-colors"
                      title="Remove Doctor"
                    >
                      <Trash2 size={18} />
                    </button>
                  </div>
                </div>
              </div>
            );
          })
        )}
      </div>

      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50">
          <div className="bg-[var(--surface)] w-full max-w-md rounded-xl p-6 shadow-xl">
            <h3 className="text-xl font-bold mb-4">{isEditMode ? 'Edit Doctor' : 'Add New Doctor'}</h3>
            {formError && <p className="text-[var(--danger)] text-sm mb-4 bg-red-50 p-2 rounded">{formError}</p>}
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-[var(--ink-muted)] mb-1">Name</label>
                <input 
                  type="text" 
                  required
                  value={name}
                  onChange={e => setName(e.target.value)}
                  className="input-field w-full"
                  placeholder="e.g. Dr. John Doe"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-[var(--ink-muted)] mb-1">Specialization (Optional)</label>
                <input 
                  type="text" 
                  value={specialization}
                  onChange={e => setSpecialization(e.target.value)}
                  className="input-field w-full"
                  placeholder="e.g. Cardiologist"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-[var(--ink-muted)] mb-1">Phone Number</label>
                <input 
                  type="text" 
                  required
                  maxLength={10}
                  value={phoneNumber}
                  onChange={e => setPhoneNumber(e.target.value.replace(/\D/g, ''))}
                  className="input-field w-full tracking-wider"
                  placeholder="10-digit mobile number"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-[var(--ink-muted)] mb-1">
                  {isEditMode ? 'New 6-Digit PIN (Leave blank to keep current)' : '6-Digit PIN'}
                </label>
                <input 
                  type="password" 
                  required={!isEditMode}
                  maxLength={6}
                  value={pin}
                  onChange={e => setPin(e.target.value.replace(/\D/g, ''))}
                  className="input-field w-full tracking-widest text-lg"
                  placeholder="123456"
                />
              </div>
              
              <div className="flex justify-end gap-3 mt-6">
                <button type="button" onClick={() => setIsModalOpen(false)} className="px-4 py-2 font-medium text-[var(--ink-muted)] hover:text-[var(--ink)]">Cancel</button>
                <button type="submit" disabled={isSubmitting} className="btn-primary">
                  {isSubmitting ? 'Saving...' : (isEditMode ? 'Save Changes' : 'Add Doctor')}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
