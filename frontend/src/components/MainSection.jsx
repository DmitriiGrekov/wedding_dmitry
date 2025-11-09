import React from 'react';
import Countdown from './Countdown';
import './MainSection.css';

const MainSection = ({ eventDate }) => {
  const scrollToEventInfo = (e) => {
    e.preventDefault();
    e.stopPropagation();
    
    // Даем небольшую задержку для рендера
    setTimeout(() => {
      // Находим оба элемента
      const eventInfo = document.querySelector('.event-info');
      const eventInfoMobile = document.querySelector('.event-info-mobile');
      
      // Проверяем, какой элемент видим
      let targetSection = null;
      
      if (eventInfo) {
        const style = window.getComputedStyle(eventInfo);
        if (style.display !== 'none') {
          targetSection = eventInfo;
        }
      }
      
      if (!targetSection && eventInfoMobile) {
        const style = window.getComputedStyle(eventInfoMobile);
        if (style.display !== 'none') {
          targetSection = eventInfoMobile;
        }
      }
      
      if (targetSection) {
        // Используем scrollIntoView - самый надежный метод
        targetSection.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        });
      } else {
        // Если элемент не найден или скрыт, скроллим на высоту экрана
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

