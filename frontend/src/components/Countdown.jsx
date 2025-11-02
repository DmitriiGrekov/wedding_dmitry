import React, { useState, useEffect } from 'react';
import './Countdown.css';

const Countdown = ({ eventDate }) => {
  const [timeLeft, setTimeLeft] = useState({
    weeks: 0,
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0
  });

  useEffect(() => {
    const calculateTimeLeft = () => {
      const now = new Date();
      const diff = eventDate - now;

      if (diff <= 0) {
        return null;
      }

      const totalSeconds = Math.floor(diff / 1000);
      const weeks = Math.floor(totalSeconds / (7 * 24 * 3600));
      const days = Math.floor((totalSeconds % (7 * 24 * 3600)) / (24 * 3600));
      const hours = Math.floor((totalSeconds % (24 * 3600)) / 3600);
      const minutes = Math.floor((totalSeconds % 3600) / 60);
      const seconds = totalSeconds % 60;

      return { weeks, days, hours, minutes, seconds };
    };

    const timer = setInterval(() => {
      const newTimeLeft = calculateTimeLeft();
      if (newTimeLeft) {
        setTimeLeft(newTimeLeft);
      }
    }, 1000);

    // Первый расчет
    const initialTimeLeft = calculateTimeLeft();
    if (initialTimeLeft) {
      setTimeLeft(initialTimeLeft);
    }

    return () => clearInterval(timer);
  }, [eventDate]);

  if (!timeLeft) {
    return <div className="countdown">Событие уже началось</div>;
  }

  return (
    <div className="countdown">
      <div className="time-block">
        <div className="time-value">{timeLeft.weeks}</div>
        <div className="time-label">недель</div>
      </div>
      <div className="time-block">
        <div className="time-value">{String(timeLeft.days).padStart(2, '0')}</div>
        <div className="time-label">дней</div>
      </div>
      <div className="time-block">
        <div className="time-value">{String(timeLeft.hours).padStart(2, '0')}</div>
        <div className="time-label">часов</div>
      </div>
      <div className="time-block">
        <div className="time-value">{String(timeLeft.minutes).padStart(2, '0')}</div>
        <div className="time-label">минут</div>
      </div>
      <div className="time-block">
        <div className="time-value">{String(timeLeft.seconds).padStart(2, '0')}</div>
        <div className="time-label">секунд</div>
      </div>
    </div>
  );
};

export default Countdown;

