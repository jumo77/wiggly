export const Section = ({title, children}) =>
  <section style={{margin:"20px 50px", borderRadius:5, backgroundColor:'white',
      display:'flex', flexDirection:'column', gap:30, padding: 20}}>
      <h1>{title}</h1>
      {children}
  </section>
