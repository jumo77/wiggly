export const successDiv = `
  <div style="width: 100vw; height: 100vh; font-size: 24px; 
  display: flex; flex-direction: column; 
  justify-content: center; align-items: center; text-align: center;">
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52" width="100" height="100">
      <circle cx="26" cy="26" r="24" fill="none" stroke="#28a745" stroke-width="3"/>
      <path fill="none" stroke="#28a745" stroke-width="3" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>
    </svg>
    <div style="margin-top: 20px;">로그인 성공!</div>
  </div>
`;

export const verifiedDiv = `
  <div style="width: 100vw; height: 100vh; font-size: 24px; 
  display: flex; flex-direction: column; 
  justify-content: center; align-items: center; text-align: center;">
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52" width="100" height="100">
      <circle cx="26" cy="26" r="24" fill="none" stroke="#28a745" stroke-width="3"/>
      <path fill="none" stroke="#28a745" stroke-width="3" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>
    </svg>
    <div style="margin-top: 20px; font-weight: bold">인증해주셔서 감사합니다!</div>
    <div style="margin-top: 20px;">인증하면 계정을 안전하게 유지하는 데 도움이 됩니다.</div>
  </div>
`;

export const denyDiv = `
  <div style="width: 100vw; height: 100vh; font-size: 24px; 
  display: flex; flex-direction: column; 
  justify-content: center; align-items: center; text-align: center;">
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 55 55" width="100" height="100">
      <circle cx="26" cy="26" r="24" fill="none" stroke="#28a745" stroke-width="3"/>
      <path fill="none" stroke="#28a745" stroke-width="3" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>
    </svg>
    <h1 style="margin-top: 20px;">이메일 제거됨</h1>
    <div style="margin-top: 20px;">회원님의 이메일 주소는 Wiggly 계정과 연결되지 않습니다.
     이메일 주소를 사용하여 새 계정에 가입하거나 다른 Wiggly 계정에 연결할 수 있습니다.</div>
  </div>
`;

export const confirmDiv = (email: string, code: string) => `
  <div style="width: 100vw; height: 100vh; font-size: 24px; 
  display: flex; flex-direction: column; 
  justify-content: center; align-items: center; text-align: center;">
    <div style="margin-top: 20px; font-weight: bold">회원님의 계정이 아니신가요?</div>
    <a href="http://localhost:3001/auth/mail/deny?email=${email}&code=${code}"
    style="width: 80%; margin:10px; padding:20px; display: block;
    box-sizing: border-box; text-align: center; text-decoration:none;
    background-color: #5db9a2; color: white;">아닙니다.</a>
  </div>
`;

export const mail = (email: string, code: string) => `
  <div style="width: 500px; font-family: sans-serif">
    <div style="background-color:lightgray; padding: 30px">
      <h1>안녕하세요. ${email.split('@')[0]}</h1>
    </div>
    <p style="padding: 10px">
      Wiggly 에 가입해 주셔서 감사합니다!
      Wiggly 은 보는 즉시 즐거움을 선사하는 좋은 형대의 모바일 동상을 위한 플랫폼일 뿐단 아니라
      자신을 있는 그대로 드러낼 수 있는 안전한 곳이기도 합니다.
    </p>
    <p style="padding: 10px">
      계정 가입을 완료하려면 이메일 주소를 인증하세요.
      이를 통해 계정을 안전하게 유지하고 암호 복구 방법으로 사용할 수 있습니다.
    </p>
    <a href='http://localhost:3001/auth/mail/verify?email=${email}&code=${code}'
    style="width: calc(100% - 20px); margin:10px; padding:20px; display: block;
    box-sizing: border-box; text-align: center; text-decoration:none;
    background-color: #5db9a2; color: white;">이메일 주소 인증</a>
    <a href="http://localhost:3001/auth/mail/confirm?email=${email}&code=${code}"
    style="color: #546dbd; text-decoration:none; font-weight: bold;
    display: block; padding: 10px">회원님의 계정이 아니신가요?</a>
  </div>
`;
