import { useState } from 'react';
import { registerWalkInNew, registerWalkInOld } from '../lib/api';

export default function WalkInRegistrationModal({ onClose }: { onClose: () => void }) {
  const [tab, setTab] = useState<'new' | 'old'>('new');
  
  // New Case State
  const [name, setName] = useState('');
  const [phoneNew, setPhoneNew] = useState('');
  const [village, setVillage] = useState('');
  const [age, setAge] = useState('');

  // Old Case State
  const [phoneOld, setPhoneOld] = useState('');
  const [caseNumber, setCaseNumber] = useState('');

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [successData, setSuccessData] = useState<{ tokenNumber: number; caseNumber?: string } | null>(null);

  const handleSubmitNew = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const res = await registerWalkInNew({
        phoneNumber: phoneNew,
        name,
        villageName: village,
        age: age ? parseInt(age) : undefined
      });
      setSuccessData({
        tokenNumber: res.token.tokenNumber,
        caseNumber: res.patient.caseNumber
      });
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmitOld = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const res = await registerWalkInOld({
        phoneNumber: phoneOld,
        caseNumber: caseNumber.trim().toUpperCase()
      });
      setSuccessData({
        tokenNumber: res.token.tokenNumber,
        caseNumber: res.patient.caseNumber
      });
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  if (successData) {
    return (
      <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
        <div className="bg-[var(--surface)] p-8 rounded-xl shadow-lg max-w-sm w-full text-center space-y-6">
          <div className="w-16 h-16 bg-green-100 text-green-600 rounded-full flex items-center justify-center mx-auto">
            <svg width="32" height="32" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2"><path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" /></svg>
          </div>
          <div>
            <h3 className="text-xl font-bold mb-2">Registration Successful</h3>
            <p className="text-[var(--ink-muted)] mb-4">Please call the patient's name when token is active.</p>
            
            <div className="bg-gray-50 border border-gray-200 rounded-lg p-4 mb-4">
               <p className="text-sm text-gray-500 uppercase font-semibold">Token Number</p>
               <p className="text-5xl font-mono font-bold text-[var(--accent)] my-2">#{successData.tokenNumber}</p>
               <p className="text-sm font-medium">Case: {successData.caseNumber}</p>
            </div>
          </div>
          <button onClick={onClose} className="btn-primary w-full">Done</button>
        </div>
      </div>
    );
  }

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
      <div className="bg-[var(--surface)] rounded-xl shadow-lg max-w-md w-full max-h-[90vh] flex flex-col overflow-hidden relative">
        <div className="p-4 border-b border-[var(--border)] flex justify-between items-center bg-[var(--surface)]">
          <h2 className="text-lg font-bold">Add Walk-in Patient</h2>
          <button onClick={onClose} className="text-[var(--ink-muted)] hover:text-[var(--ink)]">
             <svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2"><path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" /></svg>
          </button>
        </div>

        <div className="flex border-b border-[var(--border)]">
          <button 
            className={`flex-1 py-3 text-sm font-medium ${tab === 'new' ? 'border-b-2 border-[var(--ink)] text-[var(--ink)]' : 'text-[var(--ink-muted)] hover:bg-gray-50'}`}
            onClick={() => { setTab('new'); setError(''); }}
          >
            New Patient
          </button>
          <button 
            className={`flex-1 py-3 text-sm font-medium ${tab === 'old' ? 'border-b-2 border-[var(--ink)] text-[var(--ink)]' : 'text-[var(--ink-muted)] hover:bg-gray-50'}`}
            onClick={() => { setTab('old'); setError(''); }}
          >
            Returning Patient
          </button>
        </div>

        <div className="p-4 overflow-y-auto">
          {error && <div className="mb-4 p-3 bg-red-50 text-red-600 rounded-md text-sm">{error}</div>}
          
          {tab === 'new' && (
            <form onSubmit={handleSubmitNew} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-[var(--ink-muted)] mb-1">Phone Number (10 digits)</label>
                <input required type="tel" pattern="\d{10}" className="input-field" value={phoneNew} onChange={e => setPhoneNew(e.target.value)} placeholder="e.g. 9876543210" />
              </div>
              <div>
                <label className="block text-sm font-medium text-[var(--ink-muted)] mb-1">Full Name</label>
                <input required type="text" className="input-field" value={name} onChange={e => setName(e.target.value)} placeholder="Patient Name" />
              </div>
              <div>
                <label className="block text-sm font-medium text-[var(--ink-muted)] mb-1">Village Name</label>
                <input required type="text" className="input-field" value={village} onChange={e => setVillage(e.target.value)} placeholder="Village" />
              </div>
              <div>
                <label className="block text-sm font-medium text-[var(--ink-muted)] mb-1">Age (Optional)</label>
                <input type="number" className="input-field" value={age} onChange={e => setAge(e.target.value)} placeholder="Age" min="0" max="130" />
              </div>
              <button type="submit" disabled={loading} className="btn-primary w-full mt-2">
                {loading ? 'Registering...' : 'Register New Patient'}
              </button>
            </form>
          )}

          {tab === 'old' && (
            <form onSubmit={handleSubmitOld} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-[var(--ink-muted)] mb-1">Phone Number (10 digits)</label>
                <input required type="tel" pattern="\d{10}" className="input-field" value={phoneOld} onChange={e => setPhoneOld(e.target.value)} placeholder="e.g. 9876543210" />
              </div>
              <div>
                <label className="block text-sm font-medium text-[var(--ink-muted)] mb-1">Case Number</label>
                <input required type="text" className="input-field uppercase" value={caseNumber} onChange={e => setCaseNumber(e.target.value.toUpperCase())} placeholder="e.g. U-00001" />
              </div>
              <button type="submit" disabled={loading} className="btn-primary w-full mt-2">
                {loading ? 'Registering...' : 'Register Returning Patient'}
              </button>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}
