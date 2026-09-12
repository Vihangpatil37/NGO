export interface PatientDTO {
  name: string;
  phoneNumber: string;
  villageName: string;
  caseNumber: string;
  age?: number;
  preferredLanguage?: string;
  _id?: string;
}

export const toPatientDTO = (patient: any): PatientDTO | null => {
  if (!patient) return null;
  return {
    _id: patient._id?.toString(),
    name: patient.name,
    phoneNumber: patient.phoneNumber,
    villageName: patient.villageName,
    caseNumber: patient.caseNumber,
    age: patient.age,
    preferredLanguage: patient.preferredLanguage,
  };
};
