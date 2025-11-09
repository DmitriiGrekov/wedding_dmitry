import React from 'react';
import Countdown from './Countdown';
import './MainSection.css';

const MainSection = ({ eventDate }) => {
  const scrollToEventInfo = (e) => {
    e.preventDefault();
    e.stopPropagation();
    
    // Даем небольшую задержку для рендера
    setTimeout(() => {
      const eventSection = document.querySelector('.event-info');
      
      if (eventSection) {
        // Используем scrollIntoView - самый надежный метод
        
        eventSection.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        });
      } else {
        // Если элемент не найден, скроллим на высоту экрана
        window.scrollTo({
          top: window.innerHeight,
          behavior: 'smooth'
        });
      }
    }, 100);
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
        <button className="scroll-down" onClick={scrollToEventInfo} type="button">
          <img src="/arrow.png" alt="Скролл вниз" className="scroll-arrow-icon" />
        </button>
      </div>

      <div className="right-image"></div>
    </div>
  );
};

export default MainSection;

