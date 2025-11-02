import React from 'react';
import './Schedule.css';

const Schedule = () => {
  return (
    <section className="schedule">
      <h2>Свадебное расписание</h2>

      <div className="schedule-item">
        <time>10:00</time>
        <p>
          Торжественная роспись — ЗАГС. Приглашаем вас разделить вместе с нами радость создания новой
          семьи.
        </p>
      </div>

      <div className="schedule-item">
        <time>12:00</time>
        <p>
          Фуршет — Банкетный зал. После росписи вас доставят до банкетного зала 2 минивэна. Именно
          здесь мы отметим наш незабываемый день.
        </p>
      </div>

      <div className="schedule-map">
        <h3>Место проведения</h3>
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

