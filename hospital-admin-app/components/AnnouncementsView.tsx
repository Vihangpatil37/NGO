"use client";

import { useState, useEffect } from 'react';

export default function AnnouncementsView() {
  const [title, setTitle] = useState('');
  const [message, setMessage] = useState('');
  const [scope, setScope] = useState<'TODAY_PATIENTS' | 'ALL_ACTIVE_USERS'>('TODAY_PATIENTS');
  const [showConfirm, setShowConfirm] = useState(false);
  const [sending, setSending] = useState(false);
  const [history, setHistory] = useState<any[]>([]);
  const [statusMsg, setStatusMsg] = useState('');

  const loadHistory = async () => {
    try {
      const res = await fetch('http://localhost:4000/api/v1/notifications?limit=20');
      const data = await res.json();
      if (data.success) {
        setHistory(data.data.notifications || []);
      }
    } catch (_) {}
  };

  useEffect(() => {
    loadHistory();
  }, []);

  const handleBroadcast = async () => {
    setSending(true);
    setStatusMsg('');
    try {
      const token = localStorage.getItem('adminToken');
      const res = await fetch('http://localhost:4000/api/v1/notifications/broadcast', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          title,
          message,
          scope,
        }),
      });

      const data = await res.json();
      if (data.success) {
        setStatusMsg('✅ Broadcast sent successfully to all ' + (scope === 'TODAY_PATIENTS' ? "Today's Patients" : 'Active Users') + '!');
        setTitle('');
        setMessage('');
        setShowConfirm(false);
        loadHistory();
      } else {
        setStatusMsg('❌ ' + (data.error?.message || 'Failed to send broadcast'));
      }
    } catch (e: any) {
      setStatusMsg('❌ Network error sending broadcast: ' + e.message);
    } finally {
      setSending(false);
    }
  };

  return (
    <div className="p-4 space-y-6">
      <div className="bg-[var(--surface)] p-5 rounded-2xl border border-[var(--border)] shadow-sm">
        <h2 className="text-lg font-bold text-[var(--ink)] mb-1">📢 Broadcast Hospital Announcement (N04)</h2>
        <p className="text-xs text-[var(--ink-muted)] mb-4">
          Send real-time alerts & mobile push notifications to registered patients.
        </p>

        {statusMsg && (
          <div className="mb-4 p-3 rounded-lg text-sm bg-emerald-50 text-emerald-800 border border-emerald-200">
            {statusMsg}
          </div>
        )}

        <div className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-[var(--ink-muted)] uppercase mb-1">
              Target Audience (Recipient Scope)
            </label>
            <div className="flex gap-4">
              <label className="flex items-center gap-2 text-sm text-[var(--ink)] cursor-pointer">
                <input
                  type="radio"
                  name="scope"
                  checked={scope === 'TODAY_PATIENTS'}
                  onChange={() => setScope('TODAY_PATIENTS')}
                />
                Today's Registered Patients
              </label>
              <label className="flex items-center gap-2 text-sm text-[var(--ink)] cursor-pointer">
                <input
                  type="radio"
                  name="scope"
                  checked={scope === 'ALL_ACTIVE_USERS'}
                  onChange={() => setScope('ALL_ACTIVE_USERS')}
                />
                All Active App Users
              </label>
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-[var(--ink-muted)] uppercase mb-1">
              Announcement Title
            </label>
            <input
              type="text"
              placeholder="e.g. OPD Registration Closing at 12:30 PM"
              className="input-field w-full"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
            />
          </div>

          <div>
            <label className="block text-xs font-semibold text-[var(--ink-muted)] uppercase mb-1">
              Announcement Message
            </label>
            <textarea
              rows={3}
              placeholder="Enter message details for patients..."
              className="input-field w-full"
              value={message}
              onChange={(e) => setMessage(e.target.value)}
            />
          </div>

          <button
            type="button"
            disabled={!title.trim() || !message.trim()}
            onClick={() => setShowConfirm(true)}
            className="btn-primary w-full py-2.5"
          >
            Review & Broadcast Notice
          </button>
        </div>
      </div>

      {/* Confirmation Modal */}
      {showConfirm && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl p-6 max-w-md w-full shadow-2xl border border-gray-100 space-y-4">
            <h3 className="text-lg font-bold text-gray-900">⚠️ Confirm Hospital Broadcast</h3>
            <div className="bg-amber-50 border border-amber-200 p-3 rounded-xl text-xs text-amber-900 space-y-1">
              <p><strong>Audience:</strong> {scope === 'TODAY_PATIENTS' ? "Today's Patients" : 'All Active Users'}</p>
              <p><strong>Title:</strong> {title}</p>
              <p><strong>Message:</strong> {message}</p>
            </div>
            <p className="text-xs text-gray-500">
              This will immediately send an in-app alert, push notification, and real-time socket event to all target patients.
            </p>
            <div className="flex gap-3 justify-end pt-2">
              <button
                type="button"
                onClick={() => setShowConfirm(false)}
                className="px-4 py-2 text-sm font-medium text-gray-600 hover:bg-gray-100 rounded-lg"
              >
                Cancel
              </button>
              <button
                type="button"
                disabled={sending}
                onClick={handleBroadcast}
                className="px-5 py-2 text-sm font-bold text-white bg-teal-700 hover:bg-teal-800 rounded-lg shadow-sm"
              >
                {sending ? 'Broadcasting...' : 'Confirm & Send'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Notification Log / History */}
      <div className="bg-[var(--surface)] p-5 rounded-2xl border border-[var(--border)] shadow-sm">
        <h3 className="text-md font-bold text-[var(--ink)] mb-3">📋 Recent Notification Activity</h3>
        {history.length === 0 ? (
          <p className="text-xs text-[var(--ink-muted)]">No notifications dispatched yet.</p>
        ) : (
          <div className="space-y-2.5 max-h-[350px] overflow-y-auto pr-1">
            {history.map((n) => (
              <div
                key={n._id}
                className="p-3 bg-gray-50 border border-gray-200 rounded-xl flex items-start justify-between text-xs"
              >
                <div>
                  <div className="flex items-center gap-2 mb-1">
                    <span className="font-bold text-teal-800 uppercase tracking-wider text-[10px] px-1.5 py-0.5 bg-teal-100 rounded">
                      {n.type}
                    </span>
                    <span className="text-gray-400">
                      {new Date(n.createdAt).toLocaleTimeString()}
                    </span>
                  </div>
                  <p className="font-semibold text-gray-900">{n.renderedTitle || n.titleKey}</p>
                  <p className="text-gray-600">{n.renderedBody || n.bodyKey}</p>
                </div>
                <span className="text-[10px] text-gray-500 font-mono bg-white px-1.5 py-0.5 border rounded">
                  {n.delivery?.push?.status || 'stored'}
                </span>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
