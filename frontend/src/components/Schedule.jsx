import React from 'react';
import './Schedule.css';

const Schedule = () => {
  return (
    <section className="schedule">
      <h2>План празднования</h2>

      <div className="schedule-item">
        <time>15:00</time>
        <p>
          <strong>Торжественная регистрация брака</strong> — самый волнующий момент! Будем рады, если вы разделите 
          с нами эти особенные минуты, когда мы официально станем семьей ✨
          <hr/>
          <p>Место проведения: <b>микрорайон Ростоши, ул. Садовое Кольцо 40, ресторан Инконтро</b></p>
        </p>
      </div>

      <div className="schedule-item">
        <time>16:00</time>
        <p>
          <strong>Праздничный банкет</strong> — после церемонии вас ждёт вечер веселья, танцев и отличной компании! 🎉
          <hr/>
          <p>Место проведения: <b>микрорайон Ростоши, ул. Садовое Кольцо 40, ресторан Инконтро</b></p>
        </p>
      </div>

      <div className="schedule-map">
        <h3>Как нас найти</h3>
        <iframe
          src="https://yandex.ru/map-widget/v1/?um=constructor%3Aee33a1ba858e5427672eaf6a7750f77d38e46ea509913d1f14408dd25661533e&amp;source=constructor"
          width="100%"
          height="300"
          frameBorder="0"
          style={{ border: 0, borderRadius: '16px' }}
          allowFullScreen
          title="Место проведения"
        ></iframe>
      </div>
    </section>
  );
};

export default Schedule;

