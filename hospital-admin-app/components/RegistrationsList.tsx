"use client";

import { useEffect, useState } from 'react';
import { getAllRegistrations } from '../lib/api';

export default function RegistrationsList() {
  const [registrations, setRegistrations] = useState<any[]>([]);
  const [search, setSearch] = useState('');
  const [debouncedSearch, setDebouncedSearch] = useState('');
  const [loading, setLoading] = useState(true);

  // Debounce the search input
  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedSearch(search);
    }, 500);
    return () => clearTimeout(handler);
  }, [search]);

  const fetchRegistrations = async () => {
    setLoading(true);
    try {
      const data = await getAllRegistrations(debouncedSearch);
      setRegistrations(data.registrations || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRegistrations();
  }, [debouncedSearch]);

  return (
    <div className="p-4 space-y-4">
        <div className="flex justify-between items-center mb-6">
            <h2 className="text-xl font-bold">All Registrations</h2>
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
                                <p className="font-bold text-lg">{reg.patientId?.caseType === 'old' ? `Old Case ${reg.patientId?.caseNumber}` : (reg.patientId?.name || 'New Registration')}</p>
                                <p className="text-sm text-[var(--ink-muted)] mt-1">
                                    Name: <span className="font-medium text-[var(--ink)]">{reg.patientId?.name || 'N/A'}</span> • Village: <span className="font-medium text-[var(--ink)]">{reg.patientId?.villageName || 'N/A'}</span>
                                </p>
                                <p className="text-sm text-[var(--ink-muted)]">
                                    Phone: <span className="font-medium text-[var(--ink)]">{reg.patientId?.phoneNumber}</span>
                                </p>
                                <div className="mt-3 flex gap-2">
                                   <span className="text-xs px-2 py-1 bg-gray-100 rounded-full capitalize">{reg.status.replace('_', ' ')}</span>
                                   <span className="text-xs px-2 py-1 bg-blue-50 text-blue-700 rounded-full capitalize">{reg.patientId?.caseType} Case</span>
                                </div>
                            </div>
                            <div className="text-right">
                               <p className="text-sm font-semibold text-[var(--ink-muted)] mb-1">Case ID</p>
                               <p className="font-mono bg-gray-50 px-3 py-1.5 rounded-md border border-gray-200 text-lg min-w-[80px] text-center">
                                  {reg.patientId?.caseType === 'old' ? reg.patientId?.caseNumber : ' '}
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
