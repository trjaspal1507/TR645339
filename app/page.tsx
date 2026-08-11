type CropProps = {
  className: string;
  source?: "/reference-top.png" | "/reference-footer.png";
};

function ScreenshotCrop({ className, source = "/reference-top.png" }: CropProps) {
  return (
    <span className={`screenshot-crop ${className}`} aria-hidden="true">
      <img src={source} alt="" />
    </span>
  );
}

const details = [
  ["Candidate Name", "Pankaj Sharma"],
  ["Candidate ID", "TR664368"],
  ["Sector Name", "Electronics"],
  ["QP Name", "Field Technician Computing And Peripherals"],
  ["QP Code", "ELE/Q4601"],
  ["QP Version", "3.0"],
  ["Grade", "B"],
  ["Document ID", "v7uqoe8mrf92ttk6"],
  ["Issuance Date", "25-May-2026"],
  ["Valid Upto", "25-May-2028"],
  ["Type", "certificate"],
];

const linkColumns = [
  ["home", "ssc", "TP Scheme Help Video", "National Career Service", "User Manuals", "Sector & SSC", "Verify Issued Document"],
  ["DISCLAIMER", "PRIVACY_POLICY", "TERMS_CONDITIONS", "CONTACT_US", "QP Listing"],
];

export default function Home() {
  return (
    <main>
      <header>
        <div className="top-stripe" />
        <div className="utility-bar">
          <div className="utility-actions">
            <a href="#support" className="support">☎&nbsp; Technical Support</a>
            <a href="#login" className="login">LOGIN</a>
            <a href="#register">Register</a>
          </div>
        </div>
        <div className="brand-row">
          <ScreenshotCrop className="kaushal" />
          <ScreenshotCrop className="skill-india" />
          <ScreenshotCrop className="kushal" />
        </div>
        <nav aria-label="Primary"><a href="#home">HOME</a></nav>
      </header>

      <section className="certificate" id="home">
        <div className="verified-badge" aria-label="Verified">✓</div>
        <div className="verified-title">Verified</div>
        <dl>
          {details.map(([label, value]) => (
            <div key={label}><dt>{label}</dt><dd>: {value}</dd></div>
          ))}
        </dl>
      </section>

      <footer>
        <div className="footer-inner">
          <section className="links-section">
            <h2>LINKS</h2>
            <div className="link-columns">
              {linkColumns.map((column, index) => (
                <div key={index}>{column.map((item) => <a href={`#${item}`} key={item}>{item}</a>)}</div>
              ))}
            </div>
          </section>

          <section className="contact-section">
            <h2>STAY_CONTACT</h2>
            <a href="#facebook"><span className="social-icon">f</span><b>Facebook</b></a>
            <a href="#twitter"><span className="social-icon twitter">♥</span><b>Twitter</b></a>
          </section>

          <section className="apps-section">
            <div className="app-item"><p>CANDIDATE_REGISTRATION_APP_ONLINE</p><ScreenshotCrop className="play-badge" source="/reference-footer.png" /></div>
            <div className="app-item"><p>CANDIDATE_REGISTRATION_APP_OFFLINE</p><ScreenshotCrop className="play-badge" source="/reference-footer.png" /></div>
            <div className="app-item"><p>ASSESSOR_APP</p><ScreenshotCrop className="play-badge" source="/reference-footer.png" /></div>
          </section>

          <section className="partner-logos">
            <ScreenshotCrop className="nsdc" source="/reference-footer.png" />
            <ScreenshotCrop className="ncs" source="/reference-footer.png" />
          </section>
        </div>
      </footer>
    </main>
  );
}
