"use client";

import { useEffect, useState } from 'react';

export default function RegistrationsList() {
  const [registrations, setRegistrations] = useState<any[]>([]);
  const [search, setSearch] = useState('');
  const [caseTypeTab, setCaseTypeTab] = useState<'new' | 'old'>('new');
  const [loading, setLoading] = useState(true);

  const fetchRegistrations = async () => {
    setLoading(true);
    try {
      const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000';
      const token = localStorage.getItem('adminToken');
      const url = new URL(`${API_URL}/api/admin/registrations`);
      url.searchParams.append('type', caseTypeTab);
      if (search) url.searchParams.append('search', search);

      const res = await fetch(url.toString(), {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.status === 401 && typeof window !== 'undefined') {
          localStorage.removeItem('adminToken');
          window.location.reload();
      }
      const data = await res.json();
      setRegistrations(data.registrations || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRegistrations();
  }, [search, caseTypeTab]);

  return (
    <div className="p-4 space-y-4">
        <div className="flex justify-between items-center mb-6">
            <h2 className="text-xl font-bold">Today's Registrations</h2>
        </div>
        <div className="flex gap-2 bg-[var(--surface)] p-1 rounded-lg w-fit border border-[var(--border)]">
          <button 
            onClick={() => setCaseTypeTab('new')} 
            className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${caseTypeTab === 'new' ? 'bg-[var(--primary)] text-white' : 'text-[var(--ink-muted)] hover:bg-gray-50'}`}
          >
            New Cases
          </button>
          <button 
            onClick={() => setCaseTypeTab('old')} 
            className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${caseTypeTab === 'old' ? 'bg-[var(--primary)] text-white' : 'text-[var(--ink-muted)] hover:bg-gray-50'}`}
          >
            Old Cases
          </button>
        </div>

        <input 
          type="search" 
          placeholder="Search by name, phone, or case ID..." 
          value={search}
          onChange={e => setSearch(e.target.value)}
          className="input-field w-full max-w-md"
        />
        
        {loading ? <div className="text-center py-10 text-[var(--ink-muted)]">Loading registrations...</div> : (
            <div className="space-y-3">
                {registrations.length === 0 ? (
                    <div className="text-center py-10 text-[var(--ink-muted)]">No registrations found</div>
                ) : (
                    registrations.map(reg => (
                        <div key={reg._id} className="bg-[var(--surface)] p-4 rounded-lg shadow-sm border border-[var(--border)] flex justify-between items-start">
                            <div>
                                <p className="font-bold text-lg">{reg.caseType === 'old' ? `Old Case ${reg.patientId?.caseNumber}` : (reg.patientId?.name || 'New Registration')}</p>
                                <p className="text-sm text-[var(--ink-muted)] mt-1">
                                    Name: <span className="font-medium text-[var(--ink)]">{reg.patientId?.name || 'N/A'}</span> • Village: <span className="font-medium text-[var(--ink)]">{reg.patientId?.villageName || 'N/A'}</span>
                                </p>
                                <p className="text-sm text-[var(--ink-muted)]">
                                    Phone: <span className="font-medium text-[var(--ink)]">{reg.patientId?.phoneNumber}</span>
                                </p>
                                <div className="mt-3 flex gap-2">
                                   <span className="text-xs px-2 py-1 bg-gray-100 rounded-full capitalize">{reg.status.replace('_', ' ')}</span>
                                   <span className="text-xs px-2 py-1 bg-blue-50 text-blue-700 rounded-full capitalize">{reg.caseType} Case</span>
                                </div>
                            </div>
                            <div className="text-right">
                               <p className="text-sm font-semibold text-[var(--ink-muted)] mb-1">Case ID</p>
                               <p className="font-mono bg-gray-50 px-3 py-1.5 rounded-md border border-gray-200 text-lg min-w-[80px] text-center">
                                  {reg.caseType === 'old' ? reg.patientId?.caseNumber : ' '}
                               </p>
                            </div>
                        </div>
                    ))
                )}
            </div>
        )}
    </div>
  );
}
