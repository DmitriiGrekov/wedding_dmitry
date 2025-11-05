import React from 'react';
import Countdown from './Countdown';
import './MainSection.css';

const MainSection = ({ eventDate }) => {
  const scrollToEventInfo = () => {
    const eventSection = document.querySelector('.event-info');
    if (eventSection) {
      const elementPosition = eventSection.getBoundingClientRect().top;
      const offsetPosition = elementPosition + window.pageYOffset;

      window.scrollTo({
        top: offsetPosition,
        behavior: 'smooth'
      });
    }
  };

  return (
    <div className="main">
      <div className="left-image"></div>

      <div className="mid-content">
        <h1 className="names">
          Дмитрий
          <br />
          &
          <br />
          Екатерина
        </h1>

        <div className="invite">
          С радостью приглашаем вас
          <br />
          отпраздновать нашу свадьбу
        </div>
        <div className="date">18 июля</div>
        <div className="year">2026 года</div>

        <Countdown eventDate={eventDate} />
        <button className="scroll-down" onClick={scrollToEventInfo}>
          <img src="/arrow.png" alt="" className="scroll-arrow-icon" />
        </button>
      </div>

      <div className="right-image"></div>
    </div>
  );
};

export default MainSection;

