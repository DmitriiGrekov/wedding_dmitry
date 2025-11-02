import React from 'react';
import Schedule from './Schedule';
import GuestForm from './GuestForm';
import TelegramQR from './TelegramQR';
import './EventInfo.css';

const EventInfo = () => {
  return (
    <section className="event-info">
      <div className="event-overlay">
        <div className="event-content">
          <h2>
            Дорогой
            <br />
            Гость!
          </h2>

          <p>
            Мы рады сообщить Вам, что <strong>18.07.2026</strong> состоится самое главное торжество в
            нашей жизни — день нашей свадьбы!
            <br />
            Приглашаем Вас разделить с нами радость этого незабываемого дня.
          </p>

          <p>
            <strong>18.07.2026 в 10:00</strong>
          </p>

          <h3>Пожелания по подаркам</h3>
          <p>Ваше присутствие в день нашей свадьбы — самый значимый подарок для нас!</p>

          <Schedule />

          <h3>Подтверждение</h3>
          <p>
            Пожалуйста, подтвердите своё присутствие до <strong>01.01.2025</strong>.<br />
            Ждём Вас!
            <br />
          </p>

          <GuestForm />

          <TelegramQR />
        </div>
      </div>
    </section>
  );
};

export default EventInfo;

