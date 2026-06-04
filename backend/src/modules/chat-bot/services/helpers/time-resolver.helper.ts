export class TimeResolverHelper {
  public static resolveTimePeriod(timePeriod: string | undefined): {
    startDate?: string;
    endDate?: string;
  } {
    if (!timePeriod) {
      return {};
    }

    const vnNow = new Date(Date.now() + 7 * 3600_000);

    const startOf = (d: Date) => {
      const t = new Date(d);

      t.setUTCHours(0, 0, 0, 0);

      return new Date(t.getTime() - 7 * 3600_000).toISOString();
    };

    const endOf = (d: Date) => {
      const t = new Date(d);

      t.setUTCHours(23, 59, 59, 999);

      return new Date(t.getTime() - 7 * 3600_000).toISOString();
    };

    switch (timePeriod) {
      case 'today':
        return { startDate: startOf(vnNow) };
      case 'yesterday': {
        const yd = new Date(vnNow);

        yd.setUTCDate(vnNow.getUTCDate() - 1);

        return { startDate: startOf(yd), endDate: endOf(yd) };
      }
      case 'this_week': {
        const day = vnNow.getUTCDay();
        const monday = new Date(vnNow);

        monday.setUTCDate(vnNow.getUTCDate() - ((day + 6) % 7));

        return { startDate: startOf(monday) };
      }
      case 'last_week': {
        const day = vnNow.getUTCDay();
        const thisMonday = new Date(vnNow);

        thisMonday.setUTCDate(vnNow.getUTCDate() - ((day + 6) % 7));

        const lastMonday = new Date(thisMonday);

        lastMonday.setUTCDate(thisMonday.getUTCDate() - 7);
        const lastSunday = new Date(thisMonday);

        lastSunday.setUTCDate(thisMonday.getUTCDate() - 1);

        return { startDate: startOf(lastMonday), endDate: endOf(lastSunday) };
      }
      case 'this_month': {
        const firstDay = new Date(vnNow);

        firstDay.setUTCDate(1);

        return { startDate: startOf(firstDay) };
      }
      case 'last_month': {
        const firstOfThisMonth = new Date(vnNow);

        firstOfThisMonth.setUTCDate(1);
        const lastOfPrev = new Date(firstOfThisMonth);

        lastOfPrev.setUTCDate(0);
        const firstOfPrev = new Date(lastOfPrev);

        firstOfPrev.setUTCDate(1);

        return { startDate: startOf(firstOfPrev), endDate: endOf(lastOfPrev) };
      }
      default:
        return {};
    }
  }
}
