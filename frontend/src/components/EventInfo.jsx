import React, { useState, useEffect } from 'react';
import Schedule from './Schedule';
import GuestForm from './GuestForm';
import TelegramQR from './TelegramQR';
import './EventInfo.css';

const EventInfo = () => {
  const [guestNames, setGuestNames] = useState('Гость');
  const [isPlural, setIsPlural] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchInvitation = async () => {
      try {
        // Получаем UUID из URL (например, /?uuid=...)
        const urlParams = new URLSearchParams(window.location.search);
        const uuid = urlParams.get('uuid');
        const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080/api';

        if (uuid) {
          const response = await fetch(`${API_URL}/guests/invitations/by-uuid/${uuid}/`);
          
          if (response.ok) {
            const data = await response.json();
            setGuestNames(data.guest_names);
            setIsPlural(data.is_plural);
          } else {
            console.error('Приглашение не найдено');
          }
        }
      } catch (error) {
        console.error('Ошибка при загрузке приглашения:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchInvitation();
  }, []);

  const greeting = isPlural ? 'Дорогие' : 'Дорогой';

  return (
    <section className="event-info">
      <div className="event-overlay">
        <div className="event-content">
          <h2>
            {loading ? (
              <>Дорогой<br />Гость!</>
            ) : (
              <>
                {greeting}
                <br />
                {guestNames}!
              </>
            )}
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

