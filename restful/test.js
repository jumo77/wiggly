function countDailyAndMonthlyObjects() {
    const data = [
        { date: '2025-02-11T03:19:36.591Z', value: 10 },
        { date: '2025-02-11T03:19:36.591Z', value: 20 },
        { date: '2025-02-11T03:19:36.591Z', value: 30 },
        { date: '2025-02-11T03:19:36.591Z', value: 40 },
        { date: '2025-02-11T03:19:36.591Z', value: 50 },
        { date: '2025-02-11T03:19:36.591Z', value: 60 },
    ];
    const dailyCounts = {};
    const monthlyCounts = {};

    for (const item of data) {
        const date = new Date(item.date); // Date 타입 필드 이름에 따라 수정
        const year = date.getFullYear();
        const month = date.getMonth() + 1; // 0부터 시작하므로 1을 더함
        const day = date.getDate();

        // 일간 객체 수 카운트
        const dailyKey = `${year}-${month}-${day}`;
        dailyCounts[dailyKey] = (dailyCounts[dailyKey] || 0) + 1;

        // 월간 객체 수 카운트
        const monthlyKey = `${year}-${month}`;
        monthlyCounts[monthlyKey] = (monthlyCounts[monthlyKey] || 0) + 1;
    }
    console.log({ daily: dailyCounts, monthly: monthlyCounts })
    return { daily: dailyCounts, monthly: monthlyCounts };
}

countDailyAndMonthlyObjects()