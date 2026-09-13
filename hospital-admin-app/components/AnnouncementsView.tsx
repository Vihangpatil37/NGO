"use client";

import { useState, useEffect } from 'react';

import { getNotifications, broadcastAnnouncement } from '../lib/api';

export default function AnnouncementsView() {
  const [title, setTitle] = useState('');
  const [message, setMessage] = useState('');
  const [showConfirm, setShowConfirm] = useState(false);
  const [sending, setSending] = useState(false);
  const [history, setHistory] = useState<any[]>([]);
  const [statusMsg, setStatusMsg] = useState('');

  const loadHistory = async () => {
    try {
      const data = await getNotifications(20);
      setHistory(data.notifications || []);
    } catch (_) {}
  };

  useEffect(() => {
    loadHistory();
  }, []);

  const handleBroadcast = async () => {
    setSending(true);
    setStatusMsg('');
    try {
      await broadcastAnnouncement({ title, message, scope: 'ALL_ACTIVE_USERS' });
      setStatusMsg('✅ Broadcast sent successfully to all Active Users!');
      setTitle('');
      setMessage('');
      setShowConfirm(false);
      loadHistory();
    } catch (e: any) {
      console.error('Broadcast error:', e);
      setStatusMsg('❌ Unable to send announcement. Please check the details and try again.');
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
            <div className="flex items-center gap-2 text-sm text-[var(--ink)] cursor-not-allowed">
              ◉ All App Users
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
              <p><strong>Audience:</strong> All Active Users</p>
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
            {history.map((n) => {
              // Fix older N04 templates displaying {{message}}
              const actualMessage = n.renderedBody === '{{message}}' || (n.renderedBody && n.renderedBody.includes('{{message}}'))
                ? (n.variables?.customMessage || n.variables?.message || n.renderedBody)
                : (n.renderedBody || n.bodyKey);
                
              const actualTitle = (n.renderedTitle === '📢 Hospital Notice' || (n.renderedTitle && n.renderedTitle.includes('{{title}}'))) 
                ? `📢 ${n.variables?.customTitle || n.variables?.title || 'Hospital Notice'}` 
                : (n.renderedTitle || n.titleKey);

              const timeStr = new Date(n.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

              return (
                <div
                  key={n._id}
                  className="p-3 bg-gray-50 border border-gray-200 rounded-xl flex items-start justify-between text-xs"
                >
                  <div className="space-y-1">
                    <p className="font-semibold text-gray-900">{actualTitle}</p>
                    <p className="text-gray-400">{timeStr}</p>
                    <p className="text-gray-600">{actualMessage}</p>
                  </div>
                  <span className="text-[10px] text-gray-500 font-mono bg-white px-1.5 py-0.5 border rounded capitalize">
                    {n.delivery?.push?.status || 'stored'}
                  </span>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
