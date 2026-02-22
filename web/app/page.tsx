'use client'

export default function Home() {
  return (
    <>
      <div className="wave-bg">
        <div className="wave wave-1"></div>
        <div className="wave wave-2"></div>
        <div className="wave wave-3"></div>
        <div className="particles"></div>
      </div>

      <nav className="nav">
        <div className="nav-content">
          <div className="logo">Animex</div>
          <div className="nav-links">
            <a 
              href="https://github.com/Jayesh-Dev21/animex" 
              target="_blank" 
              rel="noopener noreferrer"
              className="glass-btn"
            >
              GitHub
            </a>
          </div>
        </div>
      </nav>

      <div className="container">
        <div className="hero">
          <div className="badge">CLI Anime Streaming</div>
          <h1>Animex</h1>
          <p>Stream and download anime directly from your terminal with powerful features and quality control</p>
          <div className="cta-group">
            <a href="#install" className="glass-btn primary">Get Started</a>
            <a 
              href="https://github.com/Jayesh-Dev21/animex" 
              target="_blank" 
              rel="noopener noreferrer"
              className="glass-btn secondary"
            >
              Documentation
            </a>
          </div>
        </div>

        <div className="features">
          <div className="features-grid">
            <div className="feature-item">
              <div className="feature-header">
                <div className="feature-icon quality">HD</div>
                <h3>Quality Selection</h3>
              </div>
              <p>Choose from 360p to 1080p quality. Sub and dub support.</p>
            </div>

            <div className="feature-item">
              <div className="feature-header">
                <div className="feature-icon download">↓</div>
                <h3>Download Episodes</h3>
              </div>
              <p>Download single episodes or entire seasons with ease.</p>
            </div>

            <div className="feature-item">
              <div className="feature-header">
                <div className="feature-icon history">⟳</div>
                <h3>Watch History</h3>
              </div>
              <p>Track your progress and continue where you left off.</p>
            </div>

            <div className="feature-item">
              <div className="feature-header">
                <div className="feature-icon player">▶</div>
                <h3>Multi-Player</h3>
              </div>
              <p>Works with mpv, vlc, iina, and syncplay.</p>
            </div>
          </div>
        </div>

        <div className="install-section glass" id="install">
          <h2>Installation</h2>
          <div className="code-block">
            <span className="cmd">git clone</span> <span className="string">"https://github.com/Jayesh-Dev21/animex.git"</span>{'\n'}
            <span className="cmd">cd</span> animex{'\n'}
            <span className="cmd">sudo</span> cp animex /usr/local/bin{'\n'}
            <span className="cmd">cd</span> .. && <span className="cmd">rm</span> -rf animex
          </div>
        </div>

        <div className="install-section glass">
          <h2>Quick Start</h2>
          <div className="code-block">
            <span className="comment"># Search and watch anime</span>{'\n'}
            <span className="cmd">animex</span> naruto{'\n\n'}
            <span className="comment"># Download episode</span>{'\n'}
            <span className="cmd">animex</span> <span className="flag">-d -e</span> <span className="number">5</span> one piece{'\n\n'}
            <span className="comment"># Continue from history</span>{'\n'}
            <span className="cmd">animex</span> <span className="flag">-c</span>{'\n\n'}
            <span className="comment"># Set quality</span>{'\n'}
            <span className="cmd">animex</span> <span className="flag">-q</span> <span className="number">1080</span> jujutsu kaisen
          </div>
        </div>

        <footer className="footer">
          <p>Licensed under GNU GPL v3.0</p>
          <p>Created by Jayesh-Dev21</p>
        </footer>
      </div>
    </>
  )
}
