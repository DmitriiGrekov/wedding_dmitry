import React, { useState, useEffect } from 'react';
import Schedule from './Schedule';
import GuestForm from './GuestForm';
import TelegramQR from './TelegramQR';
import './EventInfo.css';

const EventInfo = () => {
  const [guestNames, setGuestNames] = useState('Гость');
  const [isPlural, setIsPlural] = useState(false);
  const [gender, setGender] = useState('neutral');
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
            setGender(data.gender || 'neutral');
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

  // Логика выбора обращения в зависимости от пола и количества
  const getGreeting = () => {
    if (isPlural) {
      return 'Дорогие';
    }
    
    switch (gender) {
      case 'male':
        return 'Дорогой';
      case 'female':
        return 'Дорогая';
      case 'neutral':
      default:
        return 'Дорогой';
    }
  };

  const greeting = getGreeting();

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
            В этот торжественный день, <strong>18 июля 2026 года</strong>, мы очень хотим оказаться в окружении самых близких и дорогих нам людей.
          </p>

          <h3>О подарках</h3>
          <p>Ваше присутствие — лучший подарок для нас! Но если хотите порадовать нас чем-то особенным, мы будем благодарны за вклад в наше совместное будущее</p>

          <Schedule />

          <GuestForm />

          <TelegramQR />
        </div>
      </div>
    </section>
  );
};

export default EventInfo;

