export const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000';

const getAuthHeaders = () => {
    const token = typeof window !== 'undefined' ? localStorage.getItem('adminToken') : '';
    return {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
    };
};

const handleResponse = async (res: Response) => {
    if (!res.ok) {
        if (res.status === 401 && typeof window !== 'undefined') {
            localStorage.removeItem('adminToken');
            window.location.reload();
        }
        const err = await res.json().catch(() => ({}));
        throw new Error(err.error?.message || err.error || `HTTP error ${res.status}`);
    }
    const json = await res.json();
    return json.success && json.data ? json.data : json;
};

export async function login(pin: string) {
    const res = await fetch(`${API_URL}/api/admin/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ pin })
    });
    return handleResponse(res);
}

export async function getLiveQueue() {
    const res = await fetch(`${API_URL}/api/admin/queue/live`, {
        headers: getAuthHeaders()
    });
    return handleResponse(res);
}

export async function updateTokenAction(tokenId: string, action: 'call-next' | 'skip' | 'complete') {
    const res = await fetch(`${API_URL}/api/admin/queue/${tokenId}/${action}`, {
        method: 'POST',
        headers: getAuthHeaders()
    });
    return handleResponse(res);
}

export async function getAllRegistrations(search: string = '') {
    const url = new URL(`${API_URL}/api/admin/registrations`);
    if (search) url.searchParams.append('search', search);
    const res = await fetch(url.toString(), {
        headers: getAuthHeaders()
    });
    return handleResponse(res);
}

export async function getPatients(query: string = '') {
    const res = await fetch(`${API_URL}/api/admin/patients?query=${encodeURIComponent(query)}`, {
        headers: getAuthHeaders()
    });
    return handleResponse(res);
}

export async function getPatientStats() {
    const res = await fetch(`${API_URL}/api/admin/patients/stats`, {
        headers: getAuthHeaders()
    });
    return handleResponse(res);
}

export async function getPatientById(id: string) {
    const res = await fetch(`${API_URL}/api/admin/patients/${id}`, {
        headers: getAuthHeaders()
    });
    return handleResponse(res);
}

export async function updatePatient(id: string, updates: any) {
    const res = await fetch(`${API_URL}/api/admin/patients/${id}`, {
        method: 'PATCH',
        headers: getAuthHeaders(),
        body: JSON.stringify(updates)
    });
    return handleResponse(res);
}

export async function registerPatientAgain(id: string) {
    const res = await fetch(`${API_URL}/api/admin/patients/${id}/register-again`, {
        method: 'POST',
        headers: getAuthHeaders()
    });
    return handleResponse(res);
}

export async function getDoctors() {
    const res = await fetch(`${API_URL}/api/admin/doctors`, {
        headers: getAuthHeaders()
    });
    return handleResponse(res);
}

export async function addDoctor(doctorData: any) {
    const res = await fetch(`${API_URL}/api/admin/doctors`, {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify(doctorData)
    });
    return handleResponse(res);
}

export async function updateDoctor(id: string, updates: any) {
    const res = await fetch(`${API_URL}/api/admin/doctors/${id}`, {
        method: 'PATCH',
        headers: getAuthHeaders(),
        body: JSON.stringify(updates)
    });
    return handleResponse(res);
}

export async function deleteDoctor(id: string) {
    const res = await fetch(`${API_URL}/api/admin/doctors/${id}`, {
        method: 'DELETE',
        headers: getAuthHeaders()
    });
    return handleResponse(res);
}

export async function registerWalkInNew(data: { phoneNumber: string; name: string; villageName: string; age?: number }) {
    const res = await fetch(`${API_URL}/api/v1/patient/cases/new`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });
    return handleResponse(res);
}

export async function getNotifications(limit: number = 20) {
    const res = await fetch(`${API_URL}/api/v1/notifications?limit=${limit}`, {
        headers: getAuthHeaders()
    });
    return handleResponse(res);
}

export async function broadcastAnnouncement(data: { title: string; message: string; scope: string }) {
    const res = await fetch(`${API_URL}/api/v1/notifications/broadcast`, {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify(data)
    });
    return handleResponse(res);
}

export async function registerWalkInOld(data: { phoneNumber: string; caseNumber: string }) {
    const res = await fetch(`${API_URL}/api/v1/patient/queue/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });
    return handleResponse(res);
}
