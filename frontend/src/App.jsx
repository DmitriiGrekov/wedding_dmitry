import React, { useState } from 'react';
import EnvelopeAnimation from './components/EnvelopeAnimation';
import MainSection from './components/MainSection';
import EventInfo from './components/EventInfo';
import './App.css';

function App() {
  const [showContent, setShowContent] = useState(false);
  const eventDate = new Date('2026-07-18T15:00:00+03:00');

  const handleAnimationComplete = () => {
    setShowContent(true);
  };

  return (
    <div className="App">
      <EnvelopeAnimation onAnimationComplete={handleAnimationComplete} />
      
      <div className={`main-content ${showContent ? 'visible' : ''}`}>
        <MainSection eventDate={eventDate} />
        <EventInfo />
      </div>
    </div>
  );
}

export default App;

