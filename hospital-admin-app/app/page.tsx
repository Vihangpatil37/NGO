"use client";

import { useState, useEffect } from 'react';
import { login } from '../lib/api';
import QueueBoard from '../components/QueueBoard';
import RegistrationsList from '../components/RegistrationsList';
import PatientsView from '../components/PatientsView';
import DoctorsView from '../components/DoctorsView';
import AnnouncementsView from '../components/AnnouncementsView';

export default function AdminDashboard() {
  const [authed, setAuthed] = useState(false);
  const [pin, setPin] = useState('');
  const [error, setError] = useState('');
  const [activeTab, setActiveTab] = useState<'queue' | 'registrations' | 'patients' | 'doctors' | 'announcements'>('queue');
  const [globalSearch, setGlobalSearch] = useState('');
  const [searchTriggered, setSearchTriggered] = useState('');

  useEffect(() => {
    const token = localStorage.getItem('adminToken');
    if (token) setAuthed(true);
  }, []);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const res = await login(pin);
      localStorage.setItem('adminToken', res.token);
      setAuthed(true);
    } catch (err) {
      setError('Invalid PIN');
    }
  };

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (globalSearch.trim()) {
      setActiveTab('patients');
      setSearchTriggered(globalSearch.trim());
    }
  };

  const clearSearch = () => {
    setGlobalSearch('');
    setSearchTriggered('');
  };

  if (!authed) {
    return (
      <div className="min-h-screen flex items-center justify-center p-6">
        <form onSubmit={handleLogin} className="w-full max-w-sm space-y-4 text-center">
           <div className="flex justify-center mb-2">
             <img src="/logo.png" alt="ArogyaMitra Logo" className="w-20 h-20 rounded-2xl shadow-sm object-cover" />
           </div>
           <h1 className="text-2xl font-bold tracking-tight text-[var(--ink)]">ArogyaMitra</h1>
           <p className="text-sm text-[var(--ink-muted)] mb-4">Staff & Doctor Administration</p>
           {error && <p className="text-red-500 text-sm">{error}</p>}
           <input 
             type="password" 
             value={pin}
             onChange={e => setPin(e.target.value)}
             placeholder="Enter PIN (1234)"
             className="input-field text-center tracking-widest text-lg"
           />
           <button type="submit" className="btn-primary">Login</button>
        </form>
      </div>
    );
  }

  return (
    <div>
        <header className="bg-[var(--surface)] p-4 border-b border-[var(--border)] flex flex-col md:flex-row gap-4 justify-between items-center">
           <div className="flex items-center gap-3">
             <img src="/logo.png" alt="ArogyaMitra Logo" className="w-9 h-9 rounded-lg object-cover" />
             <h1 className="font-bold whitespace-nowrap text-lg">ArogyaMitra</h1>
           </div>
           
           <form onSubmit={handleSearch} className="flex-1 max-w-md flex relative">
             <input 
               type="text" 
               placeholder="Search by name, phone, case..."
               className="input-field w-full py-1.5 px-3 text-sm pr-8"
               value={globalSearch}
               onChange={e => setGlobalSearch(e.target.value)}
             />
             {globalSearch && (
               <button 
                 type="button"
                 onClick={clearSearch}
                 className="absolute right-2 top-1/2 -translate-y-1/2 text-[var(--ink-muted)] hover:text-[var(--ink)]"
               >
                 <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
               </button>
             )}
           </form>

           <button 
             onClick={() => { localStorage.removeItem('adminToken'); setAuthed(false); }}
             className="text-sm text-[var(--danger)] font-medium whitespace-nowrap"
           >
             Logout
           </button>
        </header>
        <div className="bg-[var(--surface)] border-b border-[var(--border)] flex overflow-x-auto">
           <button 
             onClick={() => setActiveTab('queue')}
             className={`flex-1 min-w-[100px] py-3 text-center font-medium text-sm transition-colors ${activeTab === 'queue' ? 'border-b-2 border-[var(--ink)] text-[var(--ink)]' : 'text-[var(--ink-muted)] hover:text-[var(--ink)]'}`}
           >
             Live Queue
           </button>
           <button 
             onClick={() => setActiveTab('registrations')}
             className={`flex-1 min-w-[100px] py-3 text-center font-medium text-sm transition-colors ${activeTab === 'registrations' ? 'border-b-2 border-[var(--ink)] text-[var(--ink)]' : 'text-[var(--ink-muted)] hover:text-[var(--ink)]'}`}
           >
             Registrations
           </button>
           <button 
             onClick={() => { setActiveTab('patients'); setSearchTriggered(''); setGlobalSearch(''); }}
             className={`flex-1 min-w-[100px] py-3 text-center font-medium text-sm transition-colors ${activeTab === 'patients' ? 'border-b-2 border-[var(--ink)] text-[var(--ink)]' : 'text-[var(--ink-muted)] hover:text-[var(--ink)]'}`}
           >
             Patients
           </button>
           <button 
             onClick={() => setActiveTab('doctors')}
             className={`flex-1 min-w-[100px] py-3 text-center font-medium text-sm transition-colors ${activeTab === 'doctors' ? 'border-b-2 border-[var(--ink)] text-[var(--ink)]' : 'text-[var(--ink-muted)] hover:text-[var(--ink)]'}`}
           >
             Doctors
           </button>
           <button 
             onClick={() => setActiveTab('announcements')}
             className={`flex-1 min-w-[100px] py-3 text-center font-medium text-sm transition-colors ${activeTab === 'announcements' ? 'border-b-2 border-[var(--ink)] text-[var(--ink)]' : 'text-[var(--ink-muted)] hover:text-[var(--ink)]'}`}
           >
             📢 Notices
           </button>
        </div>

        {activeTab === 'queue' && <QueueBoard />}
        {activeTab === 'registrations' && <RegistrationsList />}
        {activeTab === 'patients' && <PatientsView searchQuery={searchTriggered} />}
        {activeTab === 'doctors' && <DoctorsView />}
        {activeTab === 'announcements' && <AnnouncementsView />}
    </div>
  );
}
